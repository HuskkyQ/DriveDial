import Combine
import Foundation
import SwiftUI
import DriveDialCore

@MainActor
final class ClusterSession: ObservableObject {
    @Published private(set) var model: ClusterModel
    @Published var showGallery = false

    private let demo: DemoSession
    private let defaults: UserDefaults
    private var lastTick: Date?

    init(defaults: UserDefaults = .standard, now: Date = Date()) {
        self.defaults = defaults
        let theme = ThemePreference.load(from: defaults)
        demo = DemoSession(theme: theme)
        model = demo.model(now: now)
    }

    func advance(to date: Date) {
        let dt: TimeInterval
        if let lastTick {
            dt = min(1, max(0, date.timeIntervalSince(lastTick)))
        } else {
            dt = 0
        }
        self.lastTick = date
        demo.advance(by: dt)
        model = demo.model(now: date)
    }

    func setModule(_ module: ClusterModule) {
        demo.setModule(module)
        refresh()
    }

    func selectCenter(_ module: ClusterModule) {
        demo.selectCenter(module)
        refresh()
    }

    func cycleCenter(_ delta: Int) {
        var pager = CenterPagerState(module: model.module)
        guard pager.move(delta) else { return }
        demo.selectCenter(pager.module)
        refresh()
    }

    func cycleDial(_ delta: Int) {
        let forward = delta >= 0
        let next: DialSide = model.dialSide == .navigation ? .media : .navigation
        demo.setDialSide(forward ? next : next)
        refresh()
    }

    func setSettingsOpen(_ open: Bool) {
        demo.setSettingsOpen(open)
        refresh()
    }

    func stepTrack(_ delta: Int) {
        demo.stepTrack(delta)
        refresh()
    }

    func setScene(_ scene: ClusterScene) {
        demo.setScene(scene)
        refresh()
    }

    func togglePlayback() {
        demo.togglePlayback()
        refresh()
    }

    func setTheme(_ theme: ClusterTheme) {
        let result = demo.setTheme(theme, now: Date())
        if case .updated(let applied) = result {
            ThemePreference.save(applied, to: defaults)
        }
        refresh()
    }

    func setScenario(_ scenario: DemoScenario) {
        demo.setScenario(scenario)
        refresh()
    }

    func apply(page: GalleryPage) {
        _ = demo.apply(page: page, now: Date())
        showGallery = false
        refresh()
    }

    private func refresh() {
        model = demo.model(now: Date())
    }
}
