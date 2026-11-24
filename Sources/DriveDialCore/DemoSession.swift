import Foundation

/// Local demo controls. These change the simulated story, not a vehicle.
public final class DemoSession: VehicleDataProvider {
    public private(set) var scenario: DemoScenario
    public private(set) var clock: DemoClock
    public private(set) var theme: ClusterTheme
    public private(set) var module: ClusterModule
    public private(set) var scene: ClusterScene
    public private(set) var parked: Bool
    public private(set) var dialSide: DialSide
    public private(set) var navPhase: NavPhase
    public private(set) var settingsOpen: Bool

    public init(
        scenario: DemoScenario = .parked,
        clock: DemoClock = DemoClock(),
        theme: ClusterTheme = .digital,
        module: ClusterModule = .car,
        scene: ClusterScene = .cluster,
        parked: Bool? = nil,
        dialSide: DialSide = .navigation,
        navPhase: NavPhase = .active,
        settingsOpen: Bool = false
    ) {
        self.scenario = scenario
        self.clock = clock
        self.theme = theme
        self.module = module
        self.scene = scene
        self.parked = parked ?? scenario.isParked
        self.dialSide = dialSide
        self.navPhase = navPhase
        self.settingsOpen = settingsOpen
    }

    public func current(now: Date) -> LinkState {
        DemoScript.link(scenario: scenario, clock: clock, now: now)
    }

    public func model(now: Date) -> ClusterModel {
        ClusterModel(
            link: current(now: now),
            theme: theme,
            module: module,
            scene: scene,
            now: now,
            media: clock.media,
            scenario: scenario,
            parked: parked,
            dialSide: dialSide,
            navPhase: navPhase,
            settingsOpen: settingsOpen
        )
    }

    public func advance(by dt: TimeInterval) {
        clock = DemoScript.advance(clock, by: dt, scenario: scenario)
    }

    public func setScenario(_ scenario: DemoScenario) {
        self.scenario = scenario
        parked = scenario.isParked
        if scenario == .parked || scenario == .disconnected || scenario == .connecting {
            clock.elapsed = 0
        }
    }

    public func togglePlayback() {
        guard !clock.media.isEmpty else { return }
        clock.media.isPlaying.toggle()
    }

    public func stepTrack(_ delta: Int) {
        guard !clock.media.isEmpty else { return }
        let count = 3
        clock.media.trackIndex = (clock.media.trackIndex + delta + count) % count
        clock.media.progress = 0
        let titles = [("夜驶", "演示歌手 A"), ("沿河", "演示歌手 B"), ("回程", "演示组合 C")]
        let track = titles[clock.media.trackIndex]
        clock.media.title = track.0
        clock.media.artist = track.1
    }

    public func setTheme(_ theme: ClusterTheme, now: Date) -> ThemeChangeResult {
        let result = ThemePolicy.change(to: theme, parked: parked)
        if case .updated(let applied) = result {
            self.theme = applied
            if applied == .centralDial {
                scene = .cluster
            }
        }
        _ = now
        return result
    }

    public func setModule(_ module: ClusterModule) {
        self.module = module
        if theme == .centralDial {
            theme = .digital
        }
        scene = .cluster
    }

    /// Selects a center page without changing theme, scene, or wrapping past the ends.
    public func selectCenter(_ module: ClusterModule) {
        guard CenterPagerState.pages.contains(module) else { return }
        self.module = module
    }

    public func setDialSide(_ side: DialSide) {
        dialSide = side
        theme = .centralDial
        scene = .cluster
    }

    public func setScene(_ scene: ClusterScene) {
        self.scene = scene
        settingsOpen = scene == .settings
    }

    public func setSettingsOpen(_ open: Bool) {
        settingsOpen = open
        if open { scene = .settings }
    }

    /// Applies a gallery page's story. Theme still goes through `ThemePolicy`.
    public func apply(page: GalleryPage, now: Date) -> ThemeChangeResult {
        scenario = page.scenario
        clock.elapsed = page.elapsed
        clock.media = page.media
        module = page.module
        scene = page.scene
        parked = page.parked
        dialSide = page.dialSide
        navPhase = page.navPhase
        settingsOpen = page.settingsOpen
        return setTheme(page.theme, now: now)
    }
}
