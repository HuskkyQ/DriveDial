import SwiftUI
import DriveDialCore

struct SchematicMap: View {
    var progress: Double

    var body: some View {
        Canvas { context, size in
            let points = route(in: size)
            var path = Path()
            path.addLines(points)
            context.stroke(
                path,
                with: .color(DriveColor.ok),
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
            )
            let cursor = point(along: points, progress: progress)
            let marker = Path(ellipseIn: CGRect(x: cursor.x - 3.5, y: cursor.y - 3.5, width: 7, height: 7))
            context.fill(marker, with: .color(.white))
        }
        .accessibilityLabel(Copy.simulatedMap)
    }

    private func route(in size: CGSize) -> [CGPoint] {
        [
            CGPoint(x: 0.14, y: 0.78),
            CGPoint(x: 0.14, y: 0.40),
            CGPoint(x: 0.40, y: 0.40),
            CGPoint(x: 0.52, y: 0.24),
            CGPoint(x: 0.88, y: 0.24)
        ].map { CGPoint(x: $0.x * size.width, y: $0.y * size.height) }
    }

    private func point(along points: [CGPoint], progress: Double) -> CGPoint {
        guard points.count >= 2 else { return .zero }
        let spans = zip(points, points.dropFirst()).map { $0.distance(to: $1) }
        let total = spans.reduce(0, +)
        guard total > 0 else { return points[0] }
        var remaining = min(1, max(0, progress)) * total
        for (index, span) in spans.enumerated() {
            if remaining <= span || index == spans.count - 1 {
                let t = span > 0 ? remaining / span : 0
                let a = points[index]
                let b = points[index + 1]
                return CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
            }
            remaining -= span
        }
        return points[points.count - 1]
    }
}

private extension CGPoint {
    func distance(to other: CGPoint) -> Double {
        let dx = Double(x - other.x)
        let dy = Double(y - other.y)
        return (dx * dx + dy * dy).squareRoot()
    }
}

struct NavigationComboView: View {
    var model: ClusterModel
    var scale: CGFloat
    var onToggle: () -> Void
    var onSummary: () -> Void
    var interactive: Bool

    var body: some View {
        HStack(spacing: 0) {
            navColumn
            divider
            SpeedReadout(
                speed: Readings.speed(model.link),
                gear: Readings.gear(model.link),
                gearTone: Readings.gearTone(model.link),
                size: 72 * scale,
                dimmed: model.link.isStale
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            divider
            musicColumn
        }
        .padding(.horizontal, 8)
    }

    private var navColumn: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Copy.simulatedMap)
                .font(DriveFont.label(11))
                .foregroundStyle(DriveColor.tertiary)
            SchematicMap(progress: model.link.snapshot?.navigation?.progress ?? 0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if let cue = model.link.snapshot?.navigation, model.link.showsLastReading {
                Text("\(cue.maneuver) · \(ReadoutFormat.meters(cue.distanceMeters))")
                    .font(DriveFont.label(max(13, 15 * scale)))
                    .foregroundStyle(DriveColor.primary)
                    .lineLimit(1)
                Text(cue.street)
                    .font(DriveFont.label(12))
                    .foregroundStyle(DriveColor.secondary)
                    .lineLimit(1)
                Button("概要", action: { if interactive { onSummary() } })
                    .buttonStyle(.plain)
                    .font(DriveFont.label(13))
                    .foregroundStyle(DriveColor.ok)
                    .disabled(!interactive)
            } else {
                Text(Copy.noRoute)
                    .font(DriveFont.label(14))
                    .foregroundStyle(DriveColor.secondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var musicColumn: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Copy.simulatedMedia)
                .font(DriveFont.label(11))
                .foregroundStyle(DriveColor.tertiary)
            Text(model.media.title)
                .font(DriveFont.figure(max(22, 26 * scale), weight: .thin))
                .foregroundStyle(DriveColor.primary)
                .lineLimit(1)
            Text(model.media.artist)
                .font(DriveFont.label(13))
                .foregroundStyle(DriveColor.secondary)
            progress
            Button(action: { if interactive { onToggle() } }) {
                Text(model.media.isPlaying ? "暂停" : "播放")
                    .font(DriveFont.label(14))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(DriveColor.hairline, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .disabled(!interactive)
            Text(Copy.noAudio)
                .font(DriveFont.label(11))
                .foregroundStyle(DriveColor.tertiary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var progress: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(DriveColor.track)
                Capsule().fill(DriveColor.primary).frame(width: geo.size.width * model.media.progress)
            }
        }
        .frame(height: 2)
    }

    private var divider: some View {
        Rectangle().fill(DriveColor.hairline).frame(width: 1).padding(.vertical, 16)
    }
}

struct NavigationSummaryView: View {
    var model: ClusterModel
    var scale: CGFloat
    var onBackToCombo: () -> Void
    var interactive: Bool

    var body: some View {
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text(Copy.simulatedMap)
                    .font(DriveFont.label(11))
                    .foregroundStyle(DriveColor.tertiary)
                if let cue = model.link.snapshot?.navigation, model.link.showsLastReading {
                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text(cue.distanceMeters >= 1000 ? ReadoutFormat.kilometersDetail(Double(cue.distanceMeters) / 1000) : "\(cue.distanceMeters)")
                            .font(DriveFont.figure(84 * scale))
                            .monospacedDigit()
                        Text(cue.distanceMeters >= 1000 ? "" : "米")
                            .font(DriveFont.label(18))
                            .foregroundStyle(DriveColor.secondary)
                    }
                    Text(cue.maneuver)
                        .font(DriveFont.figure(32 * scale, weight: .thin))
                    Text(cue.street)
                        .font(DriveFont.label(16))
                        .foregroundStyle(DriveColor.secondary)
                    Text("剩余 \(ReadoutFormat.kilometersDetail(cue.remainingKm)) · \(ReadoutFormat.clock(cue.eta, calendar: .current)) 到达")
                        .font(DriveFont.label(13))
                        .foregroundStyle(DriveColor.secondary)
                        .monospacedDigit()
                } else {
                    Text(Copy.noRoute)
                        .font(DriveFont.figure(36, weight: .thin))
                        .foregroundStyle(DriveColor.secondary)
                }
                Button("同屏", action: { if interactive { onBackToCombo() } })
                    .buttonStyle(.plain)
                    .font(DriveFont.label(13))
                    .foregroundStyle(DriveColor.ok)
                    .disabled(!interactive)
            }
            Spacer(minLength: 0)
            SchematicMap(progress: model.link.snapshot?.navigation?.progress ?? 0)
                .frame(width: 180 * scale)
            SpeedReadout(
                speed: Readings.speed(model.link),
                gear: Readings.gear(model.link),
                gearTone: Readings.gearTone(model.link),
                size: 48 * scale,
                dimmed: model.link.isStale
            )
        }
        .foregroundStyle(DriveColor.primary)
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct MediaSceneView: View {
    var model: ClusterModel
    var scale: CGFloat
    var onToggle: () -> Void
    var interactive: Bool

    var body: some View {
        HStack(spacing: 28) {
            SpeedReadout(
                speed: Readings.speed(model.link),
                gear: Readings.gear(model.link),
                gearTone: Readings.gearTone(model.link),
                size: 48 * scale,
                dimmed: model.link.isStale
            )
            VStack(alignment: .leading, spacing: 10) {
                Text(Copy.simulatedMedia)
                    .font(DriveFont.label(12))
                    .foregroundStyle(DriveColor.tertiary)
                Text(model.media.title)
                    .font(DriveFont.figure(42 * scale, weight: .thin))
                    .lineLimit(1)
                Text(model.media.artist)
                    .font(DriveFont.label(16))
                    .foregroundStyle(DriveColor.secondary)
                progress
                    .padding(.top, 6)
                HStack(spacing: 16) {
                    Button(action: { if interactive { onToggle() } }) {
                        Text(model.media.isPlaying ? "暂停" : "播放")
                            .font(DriveFont.label(16))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .overlay(RoundedRectangle(cornerRadius: 2).stroke(DriveColor.primary.opacity(0.7), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(!interactive)
                    Text(Copy.noAudio)
                        .font(DriveFont.label(13))
                        .foregroundStyle(DriveColor.tertiary)
                }
            }
            Spacer(minLength: 0)
        }
        .foregroundStyle(DriveColor.primary)
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var progress: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(DriveColor.track)
                Capsule().fill(DriveColor.primary).frame(width: max(0, geo.size.width * model.media.progress))
            }
        }
        .frame(height: 2)
        .accessibilityLabel("播放进度")
    }
}
