import SwiftUI
import DriveDialCore

struct SpeedReadout: View {
    var speed: String
    var gear: String
    var gearTone: ReadoutTone
    var size: CGFloat
    var dimmed: Bool

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: size * 0.06) {
            Text(gear)
                .font(DriveFont.figure(size * 0.26, weight: .thin))
                .foregroundStyle(DriveColor.tone(gearTone))
            Text(speed)
                .font(DriveFont.figure(size))
                .monospacedDigit()
                .foregroundStyle(DriveColor.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
            Text("km/h")
                .font(DriveFont.label(size * 0.16))
                .foregroundStyle(DriveColor.secondary)
        }
        .opacity(dimmed ? 0.45 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("时速 \(speed) 公里每小时，\(Copy.simulatedDisclosure)")
    }
}

struct PowerTape: View {
    var kilowatts: Double
    var width: CGFloat

    var body: some View {
        let fraction = ReadoutScale.powerFraction(kilowatts)
        let tone = ReadoutToneRule.power(kilowatts: kilowatts)
        VStack(spacing: 4) {
            ZStack {
                Capsule()
                    .fill(DriveColor.track)
                    .frame(width: width, height: 1.5)
                Capsule()
                    .fill(DriveColor.tone(tone))
                    .frame(width: max(1.5, width * abs(fraction - 0.5)), height: 1.5)
                    .offset(x: (fraction - 0.5) * width / 2)
                Rectangle()
                    .fill(DriveColor.primary.opacity(0.8))
                    .frame(width: 1, height: 7)
            }
            .frame(width: width, height: 8)
            Text("\(ReadoutFormat.kilowatts(kilowatts)) kW")
                .font(DriveFont.label(12))
                .monospacedDigit()
                .foregroundStyle(DriveColor.tone(tone))
        }
        .accessibilityLabel("功率 \(ReadoutFormat.kilowatts(kilowatts)) 千瓦")
    }
}

struct ThinGauge: View {
    var fraction: Double
    var tint: Color
    var center: String
    var unit: String
    var diameter: CGFloat

    var body: some View {
        let clamped = min(1, max(0, fraction))
        ZStack {
            Circle()
                .trim(from: 0.08, to: 0.92)
                .stroke(DriveColor.track, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .rotationEffect(.degrees(90))
            Circle()
                .trim(from: 0.08, to: 0.08 + 0.84 * clamped)
                .stroke(tint, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .rotationEffect(.degrees(90))
            Canvas { context, size in
                let radius = min(size.width, size.height) / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                for mark in stride(from: 0.0, through: 1.0, by: 0.25) {
                    let theta = (0.08 + 0.84 * mark) * 2 * Double.pi + Double.pi / 2
                    var tick = Path()
                    tick.move(to: point(center, theta, radius - 2))
                    tick.addLine(to: point(center, theta, radius - 8))
                    context.stroke(tick, with: .color(.white.opacity(0.35)), style: StrokeStyle(lineWidth: 1, lineCap: .round))
                }
                let theta = (0.08 + 0.84 * clamped) * 2 * Double.pi + Double.pi / 2
                var needle = Path()
                needle.move(to: center)
                needle.addLine(to: point(center, theta, radius - 14))
                context.stroke(needle, with: .color(.white), style: StrokeStyle(lineWidth: 1, lineCap: .round))
            }
            VStack(spacing: 0) {
                Text(center)
                    .font(DriveFont.figure(diameter * 0.28))
                    .monospacedDigit()
                    .foregroundStyle(DriveColor.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(unit)
                    .font(DriveFont.label(diameter * 0.08))
                    .foregroundStyle(DriveColor.secondary)
            }
        }
        .frame(width: diameter, height: diameter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(unit) \(center)，\(Copy.simulatedDisclosure)")
    }

    private func point(_ center: CGPoint, _ theta: Double, _ radius: CGFloat) -> CGPoint {
        CGPoint(x: center.x + CGFloat(cos(theta)) * radius, y: center.y + CGFloat(sin(theta)) * radius)
    }
}

struct ClusterThemeView: View {
    var model: ClusterModel
    var layout: ClusterLayout

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch model.theme {
                case .digital:
                    digital
                case .dualDial:
                    dual
                case .centralDial:
                    central
                }
            }
            .frame(height: max(layout.speedArea.height, 1))
            Spacer(minLength: 0)
        }
    }

    private var digital: some View {
        VStack(spacing: 8 * layout.scale) {
            Spacer(minLength: 0)
            SpeedReadout(
                speed: Readings.speed(model.link),
                gear: Readings.gear(model.link),
                gearTone: Readings.gearTone(model.link),
                size: 128 * layout.scale,
                dimmed: model.link.isStale
            )
            if let snapshot = model.link.snapshot, model.link.showsLastReading {
                PowerTape(kilowatts: snapshot.powerKw, width: 220 * layout.scale)
                    .opacity(model.link.isStale ? 0.45 : 1)
            }
            Spacer(minLength: 0)
        }
    }

    private var dual: some View {
        let diameter = min(layout.speedArea.height * 0.9, layout.speedArea.width * 0.38)
        return HStack(spacing: layout.speedArea.width * 0.06) {
            ThinGauge(
                fraction: Readings.speedFraction(model.link),
                tint: DriveColor.primary,
                center: Readings.speed(model.link),
                unit: "km/h",
                diameter: diameter
            )
            ThinGauge(
                fraction: Readings.powerFraction(model.link),
                tint: DriveColor.tone(Readings.powerTone(model.link)),
                center: Readings.power(model.link),
                unit: "kW",
                diameter: diameter
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(model.link.isStale ? 0.45 : 1)
    }

    private var central: some View {
        let diameter = min(layout.speedArea.width * 0.7, layout.speedArea.height * 0.96)
        return ThinGauge(
            fraction: Readings.speedFraction(model.link),
            tint: DriveColor.primary,
            center: Readings.speed(model.link),
            unit: "km/h",
            diameter: diameter
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(model.link.isStale ? 0.45 : 1)
    }
}

enum Readings {
    static func speed(_ link: LinkState) -> String {
        guard link.showsLastReading, let value = link.snapshot?.speedKmh else { return Copy.unavailable }
        return ReadoutFormat.speedKmh(value)
    }

    static func gear(_ link: LinkState) -> String {
        guard link.showsLastReading, let gear = link.snapshot?.gear else { return Copy.unavailable }
        return gear.rawValue
    }

    static func gearTone(_ link: LinkState) -> ReadoutTone {
        guard let gear = link.snapshot?.gear, link.showsLastReading else { return .neutral }
        return ReadoutToneRule.gear(gear)
    }

    static func power(_ link: LinkState) -> String {
        guard link.showsLastReading, let value = link.snapshot?.powerKw else { return Copy.unavailable }
        return DesignSpec.wholeHero(value)
    }

    static func speedFraction(_ link: LinkState) -> Double {
        guard link.showsLastReading, let value = link.snapshot?.speedKmh else { return 0 }
        return ReadoutScale.speedFraction(value)
    }

    static func powerFraction(_ link: LinkState) -> Double {
        guard link.showsLastReading, let value = link.snapshot?.powerKw else { return 0.5 }
        return ReadoutScale.powerFraction(value)
    }

    static func powerTone(_ link: LinkState) -> ReadoutTone {
        guard link.showsLastReading, let value = link.snapshot?.powerKw else { return .neutral }
        return ReadoutToneRule.power(kilowatts: value)
    }
}
