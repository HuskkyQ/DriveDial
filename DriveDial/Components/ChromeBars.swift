import SwiftUI
import DriveDialCore

struct TopBar: View {
    var model: ClusterModel
    var scale: CGFloat

    var body: some View {
        HStack(spacing: 14 * scale) {
            Text(ReadoutFormat.clock(model.now, calendar: .current))
                .monospacedDigit()
            if let temp = model.link.snapshot?.outsideTempC, model.link.showsLastReading {
                Text(ReadoutFormat.celsius(temp))
                    .monospacedDigit()
            }
            Spacer(minLength: 8)
            Text(model.link.disclosure)
                .lineLimit(1)
            Spacer(minLength: 8)
            battery
            range
            Text(Readings.gear(model.link))
                .foregroundStyle(DriveColor.tone(Readings.gearTone(model.link)))
        }
        .font(DriveFont.label(max(12, 13 * scale), weight: .regular))
        .foregroundStyle(DriveColor.primary)
        .padding(.horizontal, 16 * scale)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) { hairline }
        .opacity(model.link.isStale ? 0.85 : 1)
    }

    @ViewBuilder
    private var battery: some View {
        if let percent = model.link.snapshot?.batteryPercent, model.link.showsLastReading {
            Text(ReadoutFormat.percent(percent))
                .monospacedDigit()
                .foregroundStyle(DriveColor.tone(ReadoutToneRule.battery(percent)))
        } else {
            Text(Copy.unavailable)
                .foregroundStyle(DriveColor.secondary)
        }
    }

    @ViewBuilder
    private var range: some View {
        if let range = model.link.snapshot?.rangeKm, model.link.showsLastReading {
            Text(ReadoutFormat.kilometers(range))
                .monospacedDigit()
                .foregroundStyle(DriveColor.secondary)
        }
    }

    private var hairline: some View {
        Rectangle().fill(DriveColor.hairline).frame(height: 1)
    }
}

struct BottomBar: View {
    var model: ClusterModel
    var scale: CGFloat
    var interactive: Bool
    var onModule: (ClusterModule) -> Void
    var onScene: (ClusterScene) -> Void
    var onTogglePlayback: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ClusterModule.allCases, id: \.self) { module in
                DashButton(
                    title: module.title,
                    selected: model.scene == .cluster && model.module == module,
                    enabled: interactive
                ) {
                    onModule(module)
                }
            }
            Spacer(minLength: 8)
            mediaChip
            Spacer(minLength: 8)
            DashButton(
                title: "导航",
                selected: model.scene == .navigationCombo || model.scene == .navigationSummary,
                enabled: interactive
            ) {
                onScene(.navigationCombo)
            }
            DashButton(title: "设置", selected: model.scene == .settings, enabled: interactive) {
                onScene(.settings)
            }
        }
        .padding(.horizontal, 10 * scale)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .top) {
            Rectangle().fill(DriveColor.hairline).frame(height: 1)
        }
    }

    private var mediaChip: some View {
        HStack(spacing: 8) {
            Button(action: { if interactive { onTogglePlayback() } }) {
                Image(systemName: model.media.isPlaying ? "pause" : "play")
                    .font(.system(size: max(11, 12 * scale), weight: .light))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .disabled(!interactive)
            .accessibilityLabel(model.media.isPlaying ? "暂停" : "播放")
            Button(action: { if interactive { onScene(.media) } }) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(model.media.title)
                        .lineLimit(1)
                    Text(Copy.simulatedMedia)
                        .font(DriveFont.label(max(9, 10 * scale)))
                        .foregroundStyle(DriveColor.tertiary)
                }
            }
            .buttonStyle(.plain)
            .disabled(!interactive)
        }
        .font(DriveFont.label(max(12, 13 * scale)))
        .foregroundStyle(model.scene == .media ? DriveColor.primary : DriveColor.secondary)
    }
}

struct DashButton: View {
    var title: String
    var selected: Bool
    var enabled: Bool
    var action: () -> Void

    var body: some View {
        Button(action: { if enabled { action() } }) {
            Text(title)
                .font(DriveFont.label(13, weight: selected ? .medium : .light))
                .foregroundStyle(selected ? DriveColor.primary : DriveColor.secondary)
                .padding(.horizontal, 8)
                .frame(maxHeight: .infinity)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(selected ? DriveColor.ok : Color.clear)
                        .frame(height: 1)
                        .padding(.bottom, 6)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}
