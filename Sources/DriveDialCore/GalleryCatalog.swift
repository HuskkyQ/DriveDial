import Foundation

public struct GalleryPage: Equatable, Identifiable, Sendable {
    public var id: String
    public var title: String
    public var scenario: DemoScenario
    public var elapsed: TimeInterval
    public var media: MediaState
    public var theme: ClusterTheme
    public var module: ClusterModule
    public var scene: ClusterScene
    public var parked: Bool
    public var dialSide: DialSide
    public var navPhase: NavPhase
    public var settingsOpen: Bool

    public init(
        id: String,
        title: String,
        scenario: DemoScenario,
        elapsed: TimeInterval = 0,
        media: MediaState = .designPaused(),
        theme: ClusterTheme,
        module: ClusterModule = .car,
        scene: ClusterScene = .cluster,
        parked: Bool = true,
        dialSide: DialSide = .navigation,
        navPhase: NavPhase = .active,
        settingsOpen: Bool = false
    ) {
        self.id = id
        self.title = title
        self.scenario = scenario
        self.elapsed = elapsed
        self.media = media
        self.theme = theme
        self.module = module
        self.scene = scene
        self.parked = parked
        self.dialSide = dialSide
        self.navPhase = navPhase
        self.settingsOpen = settingsOpen
    }

    public func model(now: Date) -> ClusterModel {
        let clock = DemoClock(elapsed: elapsed, media: media)
        return ClusterModel(
            link: DemoScript.link(scenario: scenario, clock: clock, now: now),
            theme: theme,
            module: module,
            scene: scene,
            now: now,
            media: media,
            scenario: scenario,
            parked: parked,
            dialSide: dialSide,
            navPhase: navPhase,
            settingsOpen: settingsOpen
        )
    }
}

/// The 18 independent v6 frames. Checklist items that share a frame are not duplicated.
public enum GalleryCatalog {
    public static func pages() -> [GalleryPage] { definitions }

    public static let definitions: [GalleryPage] = [
        GalleryPage(id: "clean-vehicle", title: "简洁数字 · 车模", scenario: .parked, theme: .digital, module: .car),
        GalleryPage(id: "clean-tires", title: "简洁数字 · 胎压", scenario: .parked, theme: .digital, module: .tires),
        GalleryPage(id: "clean-trip", title: "简洁数字 · 行程", scenario: .parked, theme: .digital, module: .trip),
        GalleryPage(id: "dual-vehicle", title: "双圆盘 · 车模", scenario: .parked, theme: .dualDial, module: .car),
        GalleryPage(id: "dual-tires", title: "双圆盘 · 胎压", scenario: .parked, theme: .dualDial, module: .tires),
        GalleryPage(id: "dual-trip", title: "双圆盘 · 行程", scenario: .parked, theme: .dualDial, module: .trip),
        GalleryPage(id: "dial-nav-active", title: "导航 + 车速", scenario: .parked, theme: .centralDial, dialSide: .navigation),
        GalleryPage(id: "dial-media-play", title: "导航 + 音乐 · 正在播放", scenario: .parked, media: .designPlaying(), theme: .centralDial, dialSide: .media),
        GalleryPage(id: "dial-media-pause", title: "导航 + 音乐 · 已暂停", scenario: .parked, theme: .centralDial, dialSide: .media),
        GalleryPage(id: "settings-parked", title: "停车 · 主题选择", scenario: .parked, theme: .digital, settingsOpen: true),
        GalleryPage(id: "settings-driving", title: "行驶中 · 不可改主题", scenario: .driving, theme: .digital, parked: false, settingsOpen: true),
        GalleryPage(id: "conn-connecting", title: "车辆连接中", scenario: .connecting, theme: .digital),
        GalleryPage(id: "conn-offline", title: "车辆断连", scenario: .disconnected, theme: .digital),
        GalleryPage(id: "conn-expired", title: "数据过期", scenario: .stale, theme: .digital),
        GalleryPage(id: "nav-idle", title: "导航未开始", scenario: .parked, theme: .centralDial, navPhase: .idle),
        GalleryPage(id: "nav-arrived", title: "导航到达", scenario: .parked, theme: .centralDial, navPhase: .arrived),
        GalleryPage(id: "nav-noloc", title: "导航无定位", scenario: .parked, theme: .centralDial, navPhase: .noLocation),
        GalleryPage(id: "media-none", title: "音乐无曲目", scenario: .parked, media: MediaState(title: "暂无曲目", artist: "没有正在播放的模拟曲目", isPlaying: false, progress: 0, isEmpty: true), theme: .centralDial, dialSide: .media)
    ]
}
