import Foundation

public enum Gear: String, Codable, CaseIterable, Sendable {
    case park = "P"
    case reverse = "R"
    case neutral = "N"
    case drive = "D"

    public var isParked: Bool { self == .park }

    public var title: String {
        switch self {
        case .park: return "停车"
        case .reverse: return "倒车"
        case .neutral: return "空挡"
        case .drive: return "前进"
        }
    }
}

public enum ClusterTheme: String, Codable, CaseIterable, Sendable {
    case digital
    case dualDial
    case centralDial

    public var title: String {
        switch self {
        case .digital: return "简洁数字"
        case .dualDial: return "双圆盘"
        case .centralDial: return "中央大圆"
        }
    }

    public var detail: String {
        switch self {
        case .digital: return "大数字与功率条"
        case .dualDial: return "时速与功率"
        case .centralDial: return "一个速度环"
        }
    }
}

public enum ClusterModule: String, Codable, CaseIterable, Sendable {
    case car
    case tires
    case trip

    public var title: String {
        switch self {
        case .car: return "车模"
        case .tires: return "胎压"
        case .trip: return "行程"
        }
    }

    public var artAspect: Double {
        switch self {
        case .car: return CarArtMetrics.provisional.rearWidthOverHeight
        case .tires: return CarArtMetrics.provisional.topWidthOverHeight
        case .trip: return 2.4
        }
    }
}

public enum ClusterScene: String, Codable, CaseIterable, Sendable {
    case cluster
    case navigationCombo
    case navigationSummary
    case media
    case settings

    public var title: String {
        switch self {
        case .cluster: return "仪表"
        case .navigationCombo: return "导航"
        case .navigationSummary: return "路线概要"
        case .media: return "媒体"
        case .settings: return "设置"
        }
    }
}

public struct TireReading: Equatable, Sendable {
    public var bar: Double
    public var position: String

    public init(bar: Double, position: String) {
        self.bar = bar
        self.position = position
    }

    public var tone: ReadoutTone { ReadoutToneRule.tire(bar: bar) }
}

public struct TireSet: Equatable, Sendable {
    public var frontLeft: TireReading
    public var frontRight: TireReading
    public var rearLeft: TireReading
    public var rearRight: TireReading

    public init(
        frontLeft: TireReading,
        frontRight: TireReading,
        rearLeft: TireReading,
        rearRight: TireReading
    ) {
        self.frontLeft = frontLeft
        self.frontRight = frontRight
        self.rearLeft = rearLeft
        self.rearRight = rearRight
    }

    public var all: [TireReading] { [frontLeft, frontRight, rearLeft, rearRight] }

    public static func normal() -> TireSet {
        TireSet(
            frontLeft: TireReading(bar: 2.4, position: "左前"),
            frontRight: TireReading(bar: 2.4, position: "右前"),
            rearLeft: TireReading(bar: 2.3, position: "左后"),
            rearRight: TireReading(bar: 2.3, position: "右后")
        )
    }
}

/// Fractions of the top-view slot. Provisional until the real bitmap's wheel pixels are measured.
public struct TireLabelAnchor: Equatable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public enum TireLabelAnchors {
    public static let frontLeft = TireLabelAnchor(x: 0.16, y: 0.18)
    public static let frontRight = TireLabelAnchor(x: 0.84, y: 0.18)
    public static let rearLeft = TireLabelAnchor(x: 0.16, y: 0.82)
    public static let rearRight = TireLabelAnchor(x: 0.84, y: 0.82)
}

public struct TripStats: Equatable, Sendable {
    public var distanceKm: Double
    public var energyKwh: Double
    public var duration: TimeInterval
    public var averageKmh: Double

    public init(distanceKm: Double, energyKwh: Double, duration: TimeInterval, averageKmh: Double) {
        self.distanceKm = distanceKm
        self.energyKwh = energyKwh
        self.duration = duration
        self.averageKmh = averageKmh
    }

    public static let zero = TripStats(distanceKm: 0, energyKwh: 0, duration: 0, averageKmh: 0)
}

public struct NavigationCue: Equatable, Sendable {
    public var maneuver: String
    public var street: String
    public var distanceMeters: Int
    public var remainingKm: Double
    public var eta: Date
    public var progress: Double

    public init(
        maneuver: String,
        street: String,
        distanceMeters: Int,
        remainingKm: Double,
        eta: Date,
        progress: Double
    ) {
        self.maneuver = maneuver
        self.street = street
        self.distanceMeters = distanceMeters
        self.remainingKm = remainingKm
        self.eta = eta
        self.progress = progress
    }

    public var isSimulated: Bool { true }
}

public struct MediaState: Equatable, Sendable {
    public var title: String
    public var artist: String
    public var isPlaying: Bool
    public var progress: Double

    public init(
        title: String = "夜驶",
        artist: String = "演示歌手 A",
        isPlaying: Bool = false,
        progress: Double = 72.0 / 185.0,
        trackIndex: Int = 0,
        isEmpty: Bool = false
    ) {
        self.title = title
        self.artist = artist
        self.isPlaying = isPlaying
        self.progress = min(1, max(0, progress))
        self.trackIndex = trackIndex
        self.isEmpty = isEmpty
    }

    public var trackIndex: Int
    public var isEmpty: Bool
    public var isSimulated: Bool { true }
    public static let songDuration: TimeInterval = 185

    public var position: TimeInterval { progress * Self.songDuration }

    public static func designPaused() -> MediaState {
        MediaState(isPlaying: false, progress: 72.0 / songDuration, trackIndex: 0)
    }

    public static func designPlaying() -> MediaState {
        MediaState(isPlaying: true, progress: 72.0 / songDuration, trackIndex: 0)
    }
}

public struct VehicleSnapshot: Equatable, Sendable {
    public var capturedAt: Date
    public var name: String
    public var gear: Gear
    public var speedKmh: Double
    public var powerKw: Double
    public var batteryPercent: Double
    public var rangeKm: Double
    public var outsideTempC: Double
    public var tires: TireSet
    public var trip: TripStats
    public var navigation: NavigationCue?

    public init(
        capturedAt: Date,
        name: String = "演示车辆",
        gear: Gear,
        speedKmh: Double,
        powerKw: Double,
        batteryPercent: Double,
        rangeKm: Double,
        outsideTempC: Double,
        tires: TireSet,
        trip: TripStats,
        navigation: NavigationCue?,
        odometerKm: Int = 12486,
        dateLabel: String = "周三 11/18",
        clockLabel: String = "09:42"
    ) {
        self.capturedAt = capturedAt
        self.name = name
        self.gear = gear
        self.speedKmh = speedKmh
        self.powerKw = powerKw
        self.batteryPercent = batteryPercent
        self.rangeKm = rangeKm
        self.outsideTempC = outsideTempC
        self.tires = tires
        self.trip = trip
        self.navigation = navigation
        self.odometerKm = odometerKm
        self.dateLabel = dateLabel
        self.clockLabel = clockLabel
    }

    public var odometerKm: Int
    public var dateLabel: String
    public var clockLabel: String

    public var isSimulated: Bool { true }
}

public enum DemoScenario: String, Codable, CaseIterable, Sendable {
    case parked
    case driving
    case reverse
    case lowBattery
    case tireWarning
    case disconnected
    case connecting
    case stale

    public var title: String {
        switch self {
        case .parked: return "停车"
        case .driving: return "行驶"
        case .reverse: return "倒车"
        case .lowBattery: return "低电量"
        case .tireWarning: return "胎压异常"
        case .disconnected: return "断开"
        case .connecting: return "连接中"
        case .stale: return "数据过期"
        }
    }

    public var isParked: Bool {
        switch self {
        case .driving, .reverse, .lowBattery, .tireWarning:
            return false
        case .parked, .disconnected, .connecting, .stale:
            return true
        }
    }
}

public enum DialSide: String, Codable, Sendable {
    case navigation
    case media
}

public enum NavPhase: String, Codable, Sendable {
    case active
    case idle
    case arrived
    case noLocation
}

public struct ClusterModel: Equatable, Sendable {
    public var link: LinkState
    public var theme: ClusterTheme
    public var module: ClusterModule
    public var scene: ClusterScene
    public var now: Date
    public var media: MediaState
    public var scenario: DemoScenario

    public init(
        link: LinkState,
        theme: ClusterTheme,
        module: ClusterModule,
        scene: ClusterScene,
        now: Date,
        media: MediaState,
        scenario: DemoScenario,
        parked: Bool = true,
        dialSide: DialSide = .navigation,
        navPhase: NavPhase = .active,
        settingsOpen: Bool = false
    ) {
        self.link = link
        self.theme = theme
        self.module = module
        self.scene = scene
        self.now = now
        self.media = media
        self.scenario = scenario
        self.parked = parked
        self.dialSide = dialSide
        self.navPhase = navPhase
        self.settingsOpen = settingsOpen
    }

    public var parked: Bool
    public var dialSide: DialSide
    public var navPhase: NavPhase
    public var settingsOpen: Bool
}
