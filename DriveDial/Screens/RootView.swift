import Combine
import SwiftUI
import DriveDialCore

struct RootView: View {
    @StateObject private var session = ClusterSession()

    var body: some View {
        Group {
            if session.showGallery {
                GalleryHost(
                    pages: GalleryCatalog.pages(),
                    onClose: { session.showGallery = false },
                    onApply: { session.apply(page: $0) }
                )
            } else {
                ClusterFace(
                    model: session.model,
                    onTheme: { session.setTheme($0) },
                    onSelectCenter: { session.selectCenter($0) },
                    onCycleDial: { session.cycleDial($0) },
                    onTogglePlayback: { session.togglePlayback() },
                    onStepTrack: { session.stepTrack($0) },
                    onSettings: { session.setSettingsOpen($0) },
                    onScenario: { session.setScenario($0) },
                    onOpenGallery: { session.showGallery = true }
                )
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .background(DriveColor.background)
        .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { date in
            session.advance(to: date)
        }
    }
}

struct GalleryHost: View {
    var pages: [GalleryPage]
    var onClose: () -> Void
    var onApply: (GalleryPage) -> Void
    @State private var index = 0
    @State private var frozenNow = Date()

    var body: some View {
        let page = pages[min(index, max(pages.count - 1, 0))]
        ZStack(alignment: .top) {
            ClusterFace(model: page.model(now: frozenNow), interactive: false)
            HStack(spacing: 12) {
                Button("关闭", action: onClose)
                Text(page.title).lineLimit(1)
                Text("\(index + 1) / \(pages.count)")
                    .foregroundStyle(DriveColor.secondary)
                Spacer()
                Button("上一张") { index = max(0, index - 1) }
                Button("下一张") { index = min(pages.count - 1, index + 1) }
                Button("用此页演示") { onApply(page) }
            }
            .buttonStyle(.plain)
            .font(DriveFont.cjk(13))
            .foregroundStyle(DriveColor.primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.72))
        }
        .gesture(
            DragGesture(minimumDistance: 24).onEnded { value in
                if value.translation.width < -30 { index = min(pages.count - 1, index + 1) }
                if value.translation.width > 30 { index = max(0, index - 1) }
            }
        )
    }
}
