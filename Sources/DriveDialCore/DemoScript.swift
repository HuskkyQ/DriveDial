import Foundation

public enum DriveKinematics {
    public static let cruiseKmh = 86.0
    public static let rampSeconds = 6.0

    public static func speedKmh(elapsed: TimeInterval) -> Double {
        let t = max(0, elapsed)
        if t < rampSeconds {
            return cruiseKmh * (t / rampSeconds)
        }
        return cruiseKmh + 3 * sin((t - rampSeconds) / 3)
    }

    /// Integral of `speedKmh`, in kilometres. The sine term is integrated exactly.
    public static func distanceKm(elapsed: TimeInterval) -> Double {
        let t = max(0, elapsed)
        let ramp = min(t, rampSeconds)
        let rampKm = cruiseKmh * ramp * ramp / (2 * rampSeconds) / 3600
        let cruise = max(0, t - rampSeconds)
        let cruiseKm = (cruiseKmh * cruise + (-9 * cos(cruise / 3) + 9)) / 3600
        return rampKm + cruiseKm
    }

    public static func powerKw(elapsed: TimeInterval) -> Double {
        let t = max(0, elapsed)
        if t == 0 { return 0 }
        if t < rampSeconds {
            return 8 + 48 * (1 - t / rampSeconds)
        }
        return 6 * sin((t - rampSeconds) / 2.2)
    }
}

public struct DemoClock: Equatable, Sendable {
    public var elapsed: TimeInterval
    public var media: MediaState

    public init(elapsed: TimeInterval = 0, media: MediaState = MediaState()) {
        self.elapsed = elapsed
        self.media = media
    }
}

public enum DemoScript {
    public static let staleAge: TimeInterval = 42
    public static let normalBattery = 68.0
    public static let normalRangeKm = 312.0

    public static func designFixture(now: Date, battery: Double = 68, rangeKm: Double = 312) -> VehicleSnapshot {
        VehicleSnapshot(
            capturedAt: now,
            gear: .drive,
            speedKmh: 36,
            powerKw: 12,
            batteryPercent: battery,
            rangeKm: rangeKm,
            outsideTempC: 24,
            tires: .normal(),
            trip: TripStats(distanceKm: 12.4, energyKwh: 2.1, duration: 18 * 60, averageKmh: 41),
            navigation: NavigationCue(
                maneuver: "右转",
                street: "滨河大道",
                distanceMeters: 200,
                remainingKm: 8.6,
                eta: now.addingTimeInterval(14 * 60),
                progress: 0.42
            ),
            odometerKm: 12486,
            dateLabel: "周三 11/18",
            clockLabel: "09:42"
        )
    }

    public static func advance(_ clock: DemoClock, by dt: TimeInterval, scenario: DemoScenario) -> DemoClock {
        var next = clock
        let step = max(0, dt.isFinite ? dt : 0)
        switch scenario {
        case .driving, .reverse, .lowBattery, .tireWarning:
            next.elapsed += step
        case .parked, .disconnected, .connecting, .stale:
            break
        }
        if next.media.isPlaying, MediaState.songDuration > 0 {
            var progress = next.media.progress + step / MediaState.songDuration
            progress = progress.truncatingRemainder(dividingBy: 1)
            if progress < 0 { progress += 1 }
            next.media.progress = progress
        }
        return next
    }

    public static func link(scenario: DemoScenario, clock: DemoClock, now: Date) -> LinkState {
        switch scenario {
        case .disconnected:
            return .disconnected
        case .connecting:
            return .connecting
        case .stale:
            let captured = now.addingTimeInterval(-staleAge)
            return .stale(snapshot(.driving, elapsed: 20, now: captured), age: staleAge)
        case .parked, .driving, .reverse, .lowBattery, .tireWarning:
            return .simulated(snapshot(scenario, elapsed: clock.elapsed, now: now))
        }
    }

    public static func snapshot(_ scenario: DemoScenario, elapsed: TimeInterval, now: Date) -> VehicleSnapshot {
        switch scenario {
        case .parked, .disconnected, .connecting:
            return designFixture(now: now)
        case .reverse:
            return reversing(elapsed: elapsed, now: now)
        case .driving, .stale:
            return designFixture(now: now)
        case .lowBattery:
            return moving(elapsed: elapsed, now: now, battery: 9, tires: .normal(), fixedRange: 24)
        case .tireWarning:
            var tires = TireSet.normal()
            tires.frontLeft.bar = 1.8
            return moving(elapsed: elapsed, now: now, battery: normalBattery, tires: tires)
        }
    }

    private static func parked(now: Date) -> VehicleSnapshot {
        VehicleSnapshot(
            capturedAt: now,
            gear: .park,
            speedKmh: 0,
            powerKw: 0,
            batteryPercent: normalBattery,
            rangeKm: normalRangeKm,
            outsideTempC: 18,
            tires: .normal(),
            trip: .zero,
            navigation: nil
        )
    }

    private static func reversing(elapsed: TimeInterval, now: Date) -> VehicleSnapshot {
        let t = max(0, elapsed)
        let speed = 7.0
        let distance = speed * t / 3600
        return VehicleSnapshot(
            capturedAt: now,
            gear: .reverse,
            speedKmh: speed,
            powerKw: 6,
            batteryPercent: normalBattery,
            rangeKm: normalRangeKm,
            outsideTempC: 18,
            tires: .normal(),
            trip: TripStats(
                distanceKm: distance,
                energyKwh: distance * 0.148,
                duration: t,
                averageKmh: speed
            ),
            navigation: nil
        )
    }

    private static func moving(
        elapsed: TimeInterval,
        now: Date,
        battery: Double,
        tires: TireSet,
        fixedRange: Double? = nil
    ) -> VehicleSnapshot {
        let t = max(0, elapsed)
        let distance = DriveKinematics.distanceKm(elapsed: t)
        let speed = DriveKinematics.speedKmh(elapsed: t)
        let average = t > 0.5 ? distance / t * 3600 : speed
        let range = fixedRange ?? max(20, normalRangeKm - distance * 5.4)
        return VehicleSnapshot(
            capturedAt: now,
            gear: .drive,
            speedKmh: speed,
            powerKw: DriveKinematics.powerKw(elapsed: t),
            batteryPercent: battery,
            rangeKm: range,
            outsideTempC: 18,
            tires: tires,
            trip: TripStats(
                distanceKm: distance,
                energyKwh: distance * 0.148,
                duration: t,
                averageKmh: average
            ),
            navigation: navigation(elapsed: t, now: now)
        )
    }

    public static func navigation(elapsed: TimeInterval, now: Date) -> NavigationCue {
        let distance = max(40, 520 - Int(elapsed * 14))
        let passed = elapsed > 34
        let remaining = max(0.4, 6.8 - elapsed * 0.04)
        return NavigationCue(
            maneuver: passed ? "直行" : "右转",
            street: passed ? "延安高架" : "世纪大道",
            distanceMeters: passed ? 800 : distance,
            remainingKm: remaining,
            eta: now.addingTimeInterval(remaining / 42 * 3600),
            progress: min(0.92, max(0, elapsed / 80))
        )
    }
}
