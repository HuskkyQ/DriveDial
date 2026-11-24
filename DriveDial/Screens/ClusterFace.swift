import SwiftUI
import DriveDialCore

struct ClusterFace: View {
    var model: ClusterModel
    var interactive = true
    var onTheme: (ClusterTheme) -> Void = { _ in }
    var onSelectCenter: (ClusterModule) -> Void = { _ in }
    @State private var centerPager = CenterPagerState(module: .car)
    @State private var centerDrag: CGFloat = 0
    @State private var centerDragging = false
    var onCycleDial: (Int) -> Void = { _ in }
    var onTogglePlayback: () -> Void = {}
    var onStepTrack: (Int) -> Void = { _ in }
    var onSettings: (Bool) -> Void = { _ in }
    var onScenario: (DemoScenario) -> Void = { _ in }
    var onOpenGallery: () -> Void = {}

    var body: some View {
        GeometryReader { geo in
            let safe = LayoutInsets(
                top: geo.safeAreaInsets.top,
                leading: geo.safeAreaInsets.leading,
                bottom: geo.safeAreaInsets.bottom,
                trailing: geo.safeAreaInsets.trailing
            )
            let board = PlacedBoard.place(
                canvas: LayoutSize(width: geo.size.width, height: geo.size.height),
                safe: safe
            )
            let clearance = ChromeClearanceLayout.place(
                safeLeading: safe.leading,
                safeTrailing: safe.trailing,
                scale: board.scale
            )
            ZStack(alignment: .topLeading) {
                DriveColor.background
                boardView(clearance: clearance)
                    .frame(width: 874, height: 402, alignment: .topLeading)
                    .scaleEffect(CGFloat(board.scale), anchor: .topLeading)
                    .frame(
                        width: max(CGFloat(board.boardWidth), 1),
                        height: max(CGFloat(board.boardHeight), 1),
                        alignment: .topLeading
                    )
                    .offset(x: CGFloat(board.originX), y: CGFloat(board.originY))
            }
        }
        .ignoresSafeArea()
        .onAppear {
            centerPager = CenterPagerState(module: model.module)
        }
        .onChange(of: model.module) { _, module in
            let incoming = CenterPagerState(module: module)
            guard incoming.index != centerPager.index, !centerDragging else { return }
            withAnimation(.easeInOut(duration: 0.32)) {
                centerPager = incoming
                centerDrag = 0
            }
        }
    }

    private func boardView(clearance: ChromeClearance) -> some View {
        ZStack(alignment: .topLeading) {
            boardBackground
            switch model.theme {
            case .digital:
                cleanNumbers
            case .dualDial:
                dualGauges
            case .centralDial:
                centralDial
            }
            if model.theme != .centralDial {
                centerModule
            }
            if model.theme != .centralDial {
                moduleArrows
            }
            topChrome(clearance)
            bottomChrome
            if model.settingsOpen {
                settingsSheet
            }
        }
        .frame(width: 874, height: 402)
        .clipped()
    }

    private var boardBackground: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            context.fill(
                Path(rect),
                with: .linearGradient(
                    Gradient(stops: [
                        .init(color: Color(rgb: 0x070B12), location: 0),
                        .init(color: Color(rgb: 0x05070C), location: DesignSpec.Background.gradientMiddleOffset.pt),
                        .init(color: Color(rgb: 0x04060A), location: 1)
                    ]),
                    startPoint: CGPoint(x: size.width / 2, y: 0),
                    endPoint: CGPoint(x: size.width / 2, y: size.height)
                )
            )
            var glow = context
            glow.translateBy(x: DesignSpec.Background.ellipseCX.pt, y: DesignSpec.Background.ellipseCY.pt)
            glow.scaleBy(x: 1, y: DesignSpec.Background.ellipseRY.pt / DesignSpec.Background.ellipseRX.pt)
            let diameter = DesignSpec.Background.ellipseRX.pt * 2
            let bounds = CGRect(x: -DesignSpec.Background.ellipseRX.pt, y: -DesignSpec.Background.ellipseRX.pt, width: diameter, height: diameter)
            glow.fill(
                Path(ellipseIn: bounds),
                with: .radialGradient(
                    Gradient(stops: [
                        .init(color: Color(rgb: 0x15283C).opacity(DesignSpec.Background.glowCenterOpacity), location: 0),
                        .init(color: Color(rgb: 0x163056).opacity(DesignSpec.Background.glowMidOpacity), location: DesignSpec.Background.glowMidOffset.pt),
                        .init(color: Color(rgb: 0x05070C).opacity(DesignSpec.Background.glowEdgeOpacity), location: 1)
                    ]),
                    center: .zero,
                    startRadius: 0,
                    endRadius: DesignSpec.Background.ellipseRX.pt
                )
            )
        }
        .frame(width: DesignSpec.artboardWidth.pt, height: DesignSpec.artboardHeight.pt)
    }

    private var cleanNumbers: some View {
        ZStack(alignment: .topLeading) {
            heroBlock(
                title: "速度",
                value: Readings.speed(model.link),
                unit: "km/h",
                x: DesignSpec.CleanHero.speedX.pt,
                marker: "hero-speed"
            )
            heroBlock(
                title: "功率",
                value: Readings.power(model.link),
                unit: "kW",
                x: DesignSpec.CleanHero.powerX.pt,
                marker: "hero-power"
            )
        }
        .frame(width: DesignSpec.artboardWidth.pt, height: DesignSpec.artboardHeight.pt, alignment: .topLeading)
    }

    private func heroBlock(title: String, value: String, unit: String, x: CGFloat, marker: String) -> some View {
        ZStack(alignment: .topLeading) {
            SvgText(text: title, font: DriveFont.cjk(DesignSpec.CleanHero.labelSize.pt), color: DriveColor.tertiary, tracking: DesignSpec.CleanHero.labelTracking.pt, x: x, baseline: DesignSpec.CleanHero.labelY.pt, marker: "\(marker)-label")
            SvgText(text: value, font: DriveFont.figure(DesignSpec.CleanHero.fontSize.pt), color: DriveColor.primary, tracking: DesignSpec.CleanHero.letterSpacing.pt, x: x, baseline: DesignSpec.CleanHero.baselineY.pt, opacity: model.link.isStale ? 0.78 : 1, marker: "\(marker)-value")
            // Same 874×402 sibling the old stroke used as the alignment origin.
            // SvgText guides are not visible to a parent ZStack, so this frame
            // has to stay inside this stack. It draws nothing.
            Color.clear
                .frame(width: DesignSpec.artboardWidth.pt, height: DesignSpec.artboardHeight.pt)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            if model.link.showsLastReading {
                SvgText(text: unit, font: DriveFont.regular(DesignSpec.CleanHero.unitSize.pt), color: DriveColor.secondary.opacity(DesignSpec.CleanHero.unitOpacity), tracking: DesignSpec.CleanHero.unitTracking.pt, x: x, baseline: DesignSpec.CleanHero.unitY.pt, marker: "\(marker)-unit")
            }
        }
    }

    private var dualGauges: some View {
        ZStack {
            silverArc.frame(width: 250, height: 250).position(x: 174.97, y: 216.4)
            silverArc.frame(width: 250, height: 250).position(x: 704.15, y: 216.4)
            dualReadout(title: "速度", value: Readings.speed(model.link), unit: "km/h", x: 174.97)
            dualReadout(title: "功率", value: Readings.power(model.link), unit: "kW", x: 704.15)
        }
    }

    private var silverArc: some View {
        Circle()
            .trim(from: 0.08, to: 0.78)
            .stroke(DriveColor.track, style: StrokeStyle(lineWidth: 3.2, lineCap: .round))
            .rotationEffect(.degrees(118))
    }

    private func dualReadout(title: String, value: String, unit: String, x: CGFloat) -> some View {
        ZStack {
            Text(title)
                .font(DriveFont.cjk(11))
                .tracking(2.2)
                .foregroundStyle(DriveColor.tertiary)
                .position(x: x, y: 178)
            Text(value)
                .font(DriveFont.figure(58))
                .foregroundStyle(DriveColor.primary)
                .opacity(model.link.isStale ? 0.78 : 1)
                .position(x: x, y: 214)
            if model.link.showsLastReading {
                Text(unit)
                    .font(DriveFont.regular(12))
                    .tracking(1.6)
                    .foregroundStyle(DriveColor.secondary)
                    .position(x: x, y: 246)
            }
        }
    }

    private var centralDial: some View {
        ZStack {
            Circle()
                .stroke(DriveColor.track, lineWidth: 3.6)
                .frame(width: 240, height: 240)
                .position(x: 437, y: 180)
            Text("速度")
                .font(DriveFont.cjk(11))
                .tracking(2.2)
                .foregroundStyle(DriveColor.tertiary)
                .position(x: 437, y: 132)
            Text(Readings.speed(model.link))
                .font(DriveFont.figure(92))
                .foregroundStyle(DriveColor.primary)
                .opacity(model.link.isStale ? 0.78 : 1)
                .position(x: 437, y: 178)
            if model.link.showsLastReading {
                Text("km/h")
                    .font(DriveFont.regular(12))
                    .tracking(1.6)
                    .foregroundStyle(DriveColor.secondary)
                    .position(x: 437, y: 224)
            }
            mapPanel.position(x: 177, y: 180)
            rightPanel.position(x: 697, y: 180)
            moduleArrowsRight
        }
    }

    private var mapPanel: some View {
        ZStack(alignment: .topLeading) {
            SchematicMap(progress: model.navPhase == .idle || model.navPhase == .noLocation ? 0 : 0.62)
                .frame(width: 236, height: 272)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            turnBanner
                .padding(8)
            Text(model.navPhase == .noLocation ? "设计示意 · 无定位" : Copy.simulatedMap)
                .font(DriveFont.cjk(8))
                .foregroundStyle(DriveColor.tertiary)
                .frame(width: 236)
                .position(x: 118, y: 258)
        }
        .frame(width: 236, height: 272)
    }

    private var turnBanner: some View {
        HStack(spacing: 8) {
            Circle()
                .stroke(DriveColor.cyan, lineWidth: 1.2)
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: turnSymbol)
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(DriveColor.cyan)
                )
            VStack(alignment: .leading, spacing: 1) {
                Text(turnDistance)
                    .font(DriveFont.medium(16))
                    .foregroundStyle(DriveColor.cyan)
                Text(turnTitle)
                    .font(DriveFont.cjk(12, weight: .semibold))
                    .foregroundStyle(DriveColor.primary)
                Text(model.navPhase == .active ? "模拟 · 非实况导航" : "设计示意 · 不是实装或实测")
                    .font(DriveFont.cjk(8))
                    .foregroundStyle(DriveColor.tertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(Color(red: 8 / 255, green: 12 / 255, blue: 20 / 255).opacity(0.9))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(DriveColor.hairline, lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var turnSymbol: String {
        switch model.navPhase {
        case .active: return "arrow.turn.up.right"
        case .arrived: return "flag.checkered"
        case .idle, .noLocation: return "location.slash"
        }
    }

    private var turnDistance: String {
        switch model.navPhase {
        case .active: return "200 米"
        case .arrived: return "0 米"
        case .idle, .noLocation: return "--"
        }
    }

    private var turnTitle: String {
        switch model.navPhase {
        case .active: return "右转 滨河大道"
        case .arrived: return "已到达"
        case .idle: return "导航未开始"
        case .noLocation: return "无法定位"
        }
    }

    private var rightPanel: some View {
        Group {
            if model.dialSide == .navigation {
                navSummary
            } else {
                mediaPanel
            }
        }
        .frame(width: 220, height: 250, alignment: .topLeading)
    }

    private var navSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("导航摘要 · 模拟")
                .font(DriveFont.cjk(10))
                .tracking(1.4)
                .foregroundStyle(DriveColor.tertiary)
            Text(navDestination)
                .font(DriveFont.cjk(16))
                .foregroundStyle(DriveColor.primary)
            row("剩余", navRemain)
            row("预计", navEta)
            row("到达", model.navPhase == .active ? "09:56" : "--")
            row("到达电量", model.navPhase == .active ? "62%" : "--")
            Text("导航信息为界面演示，不连接真实地图或车辆定位。")
                .font(DriveFont.cjk(9))
                .foregroundStyle(DriveColor.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var navDestination: String {
        switch model.navPhase {
        case .active, .arrived: return "市中心停车场"
        case .idle: return "未设置目的地"
        case .noLocation: return "无法确定位置"
        }
    }

    private var navRemain: String {
        switch model.navPhase {
        case .active: return "8.6 km"
        case .arrived: return "0 km"
        case .idle, .noLocation: return "--"
        }
    }

    private var navEta: String {
        switch model.navPhase {
        case .active: return "14 分钟"
        case .arrived: return "已到达"
        case .idle, .noLocation: return "--"
        }
    }

    private func row(_ name: String, _ value: String) -> some View {
        HStack {
            Text(name).foregroundStyle(DriveColor.tertiary)
            Spacer()
            Text(value).font(DriveFont.medium(12)).foregroundStyle(DriveColor.primary)
        }
        .font(DriveFont.cjk(12))
    }

    private var mediaPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(mediaStatus)
                    .font(DriveFont.cjk(11))
                    .tracking(1.6)
                    .foregroundStyle(DriveColor.tertiary)
                Spacer()
                Text(Copy.simulatedMedia)
                    .font(DriveFont.cjk(9))
                    .foregroundStyle(DriveColor.tertiary)
            }
            Text(model.media.isEmpty ? "暂无曲目" : model.media.title)
                .font(DriveFont.cjk(18))
                .foregroundStyle(DriveColor.primary)
            Text(model.media.isEmpty ? "没有正在播放的模拟曲目" : model.media.artist)
                .font(DriveFont.cjk(12))
                .foregroundStyle(DriveColor.secondary)
            progressBar
            HStack {
                Text(model.media.isEmpty ? "--" : clock(model.media.position))
                Spacer()
                Text(model.media.isEmpty ? "--" : "3:05")
            }
            .font(DriveFont.regular(11))
            .foregroundStyle(DriveColor.tertiary)
            if interactive, !model.media.isEmpty {
                HStack(spacing: 16) {
                    Button("上一首") { onStepTrack(-1) }
                    Button(model.media.isPlaying ? "暂停" : "播放") { onTogglePlayback() }
                    Button("下一首") { onStepTrack(1) }
                }
                .buttonStyle(.plain)
                .font(DriveFont.cjk(13))
                .foregroundStyle(DriveColor.primary)
            }
            Text(Copy.noAudio)
                .font(DriveFont.cjk(9))
                .foregroundStyle(DriveColor.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var mediaStatus: String {
        if model.media.isEmpty { return "暂无曲目" }
        return model.media.isPlaying ? "正在播放" : "已暂停"
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.12))
                Capsule()
                    .fill(Color.white.opacity(0.62))
                    .frame(width: model.media.isEmpty ? 0 : geo.size.width * model.media.progress)
            }
        }
        .frame(height: 3)
    }

    private func clock(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds.rounded()))
        return "\(total / 60):" + String(format: "%02d", total % 60)
    }

    private var centerModule: some View {
        let width = CenterStrip.width.pt
        let height = CenterStrip.height.pt
        return HStack(spacing: 0) {
            ForEach(CenterPagerState.pages, id: \.self) { module in
                centerPage(module)
                    .frame(width: width, height: height)
            }
        }
        .offset(x: -CGFloat(centerPager.index) * width + centerDrag)
        .frame(width: width, height: height, alignment: .leading)
        .clipped()
        .contentShape(Rectangle())
        .gesture(centerDragGesture(pageWidth: width))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("center-pager")
        .position(
            x: CenterStrip.originX.pt + width / 2,
            y: CenterStrip.originY.pt + height / 2
        )
    }

    private func centerDragGesture(pageWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                centerDragging = true
                let resisted = centerPager.resistedTranslation(Double(value.translation.width))
                centerDrag = CGFloat(resisted)
            }
            .onEnded { value in
                var next = centerPager
                let moved = next.settle(translation: Double(value.translation.width), pageWidth: Double(pageWidth))
                centerDragging = false
                withAnimation(.easeInOut(duration: 0.32)) {
                    centerDrag = 0
                    centerPager = next
                }
                if moved {
                    onSelectCenter(next.module)
                }
            }
    }

    private func shiftCenter(_ delta: Int) {
        guard !centerDragging else { return }
        var next = centerPager
        guard next.move(delta) else { return }
        withAnimation(.easeInOut(duration: 0.32)) {
            centerDrag = 0
            centerPager = next
        }
        onSelectCenter(next.module)
    }

    @ViewBuilder
    private func centerPage(_ module: ClusterModule) -> some View {
        ZStack {
            switch module {
            case .car:
                if model.theme == .digital {
                    RoadTrapezoid()
                        .frame(width: CGFloat(DesignBoard.road.width), height: CGFloat(DesignBoard.road.height))
                        .position(x: localX(DesignBoard.road.midX), y: localY(DesignBoard.road.midY))
                        .opacity(model.link.showsLastReading ? 1 : 0.4)
                }
                BitmapCar(name: "CarRear", label: "白色三厢车后上方俯视，车头朝上")
                    .frame(width: CGFloat(carBox.width), height: CGFloat(carBox.height))
                    .position(x: localX(carBox.midX), y: localY(carBox.midY))
                    .opacity(model.link.showsLastReading ? 1 : 0.35)
            case .tires:
                BitmapCar(name: "CarTop", label: "白色三厢车正俯视")
                    .frame(width: CGFloat(DesignBoard.topCar.width), height: CGFloat(DesignBoard.topCar.height))
                    .position(x: localX(DesignBoard.topCar.midX), y: localY(DesignBoard.topCar.midY))
                    .opacity(model.link.isStale ? 0.78 : 1)
                tireLabels
            case .trip:
                tripCard.position(x: localX(CenterGroup.tripCenter.x), y: localY(CenterGroup.tripCenter.y))
            }
        }
        .accessibilityIdentifier("center-page-\(module.rawValue)")
    }

    private func localX(_ boardX: Double) -> CGFloat {
        CGFloat(boardX - CenterStrip.originX)
    }

    private func localY(_ boardY: Double) -> CGFloat {
        CGFloat(boardY - CenterStrip.originY)
    }

    private var carBox: DesignRect {
        model.theme == .dualDial ? DesignBoard.dualCar : DesignBoard.rearCar
    }

    private var tireLabels: some View {
        let names = ["左前", "右前", "左后", "右后"]
        let readings: [String] = model.link.showsLastReading
            ? [
                tireText(model.link.snapshot?.tires.frontLeft.bar),
                tireText(model.link.snapshot?.tires.frontRight.bar),
                tireText(model.link.snapshot?.tires.rearLeft.bar),
                tireText(model.link.snapshot?.tires.rearRight.bar)
            ]
            : ["--", "--", "--", "--"]
        let spots = CenterGroup.tireSpots
        return ZStack {
            ForEach(0..<spots.count, id: \.self) { index in
                let spot = spots[index]
                VStack(spacing: 1) {
                    Text(names[index]).font(DriveFont.cjk(9)).foregroundStyle(DriveColor.tertiary)
                    Text(readings[index]).font(DriveFont.regular(16)).foregroundStyle(DriveColor.primary)
                    if model.link.showsLastReading {
                        Text("正常").font(DriveFont.cjk(8)).foregroundStyle(DriveColor.ok)
                    }
                }
                .position(x: spot.x.pt - CenterStrip.originX.pt, y: spot.y.pt - CenterStrip.originY.pt)
            }
        }
    }

    private func tireText(_ bar: Double?) -> String {
        guard let bar else { return "--" }
        return ReadoutFormat.bar(bar)
    }

    private var tripCard: some View {
        let trip = model.link.snapshot?.trip
        return VStack(spacing: 4) {
            Text(Copy.tripTitle)
                .font(DriveFont.cjk(11))
                .tracking(2.2)
                .foregroundStyle(DriveColor.tertiary)
            Text(model.link.showsLastReading ? "12.4" : "--")
                .font(DriveFont.figure(48))
                .foregroundStyle(DriveColor.primary)
            if model.link.showsLastReading {
                Text("km").font(DriveFont.regular(12)).foregroundStyle(DriveColor.secondary)
            }
            HStack(spacing: 18) {
                tripCell("时长", model.link.showsLastReading ? "18 min" : "--")
                tripCell("均速", model.link.showsLastReading ? "41 km/h" : "--")
                tripCell("耗电", model.link.showsLastReading ? "2.1 kWh" : "--")
            }
            .padding(.top, 8)
            Text("模拟数据 · 非真实行程记录")
                .font(DriveFont.cjk(10))
                .foregroundStyle(DriveColor.tertiary)
                .padding(.top, 8)
        }
        .frame(width: 250)
        .opacity(trip == nil && model.link.showsLastReading ? 1 : 1)
    }

    private func tripCell(_ name: String, _ value: String) -> some View {
        VStack(spacing: 4) {
            Text(name).font(DriveFont.cjk(9)).foregroundStyle(DriveColor.tertiary)
            Text(value).font(DriveFont.regular(15)).foregroundStyle(DriveColor.primary)
        }
    }

    private var moduleArrows: some View {
        ZStack {
            arrowButton(
                system: "chevron.left",
                x: DesignSpec.Arrows.previousLeft.pt + DesignSpec.Arrows.side.pt / 2,
                y: DesignSpec.arrowCenterY.pt,
                enabled: centerPager.canRetreat,
                identifier: "center-previous"
            ) { shiftCenter(-1) }
            arrowButton(
                system: "chevron.right",
                x: DesignSpec.Arrows.nextLeft.pt + DesignSpec.Arrows.side.pt / 2,
                y: DesignSpec.arrowCenterY.pt,
                enabled: centerPager.canAdvance,
                identifier: "center-next"
            ) { shiftCenter(1) }
            HStack(spacing: 6) {
                ForEach(Array(CenterPagerState.pages.enumerated()), id: \.offset) { index, _ in
                    Circle()
                        .fill(index == centerPager.index ? DriveColor.secondary : Color.white.opacity(0.22))
                        .frame(width: 5, height: 5)
                        .accessibilityElement()
                        .accessibilityIdentifier("center-dot-\(index)")
                        .accessibilityValue(index == centerPager.index ? "selected" : "idle")
                }
            }
            .position(x: DesignSpec.artboardWidth.pt / 2, y: DesignSpec.dotsBottomEdgeY.pt - DesignSpec.Dots.diameter.pt / 2)
        }
    }

    private var moduleArrowsRight: some View {
        ZStack {
            arrowButton(system: "chevron.left", x: 569, y: 180) { onCycleDial(-1) }
            arrowButton(system: "chevron.right", x: 825, y: 180) { onCycleDial(1) }
        }
    }

    private func arrowButton(
        system: String,
        x: CGFloat,
        y: CGFloat,
        enabled: Bool = true,
        identifier: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: { if interactive, enabled { action() } }) {
            Image(systemName: system)
                .font(.system(size: 16, weight: .light))
                .foregroundStyle(Color.white.opacity(enabled ? 0.4 : 0.15))
                .frame(width: DesignSpec.Arrows.side.pt, height: DesignSpec.Arrows.side.pt)
        }
        .buttonStyle(.plain)
        .disabled(!interactive || !enabled)
        .accessibilityIdentifier(identifier ?? system)
        .position(x: x, y: y)
    }

    private func topChrome(_ clearance: ChromeClearance) -> some View {
        Color.clear
            .frame(width: DesignSpec.artboardWidth.pt, height: DesignSpec.artboardHeight.pt)
            .overlay(alignment: .topLeading) {
                Text(model.link.readyLabel)
                    .font(model.link.isLiveSimulation ? DriveFont.medium(DesignSpec.Ready.fontSize.pt) : DriveFont.cjk(DesignSpec.Ready.fontSize.pt))
                    .tracking(model.link.isLiveSimulation ? DesignSpec.Ready.fontSize.pt * DesignSpec.Ready.letterSpacingEm.pt : 1)
                    .foregroundStyle(statusColor)
                    .fixedSize()
                    .padding(.leading, clearance.readyLeft.pt)
                    .padding(.top, DesignSpec.Ready.top.pt)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .overlay(alignment: .topLeading) {
                TelltaleRow()
                    .padding(.leading, clearance.telltaleLeft.pt)
                    .padding(.top, DesignSpec.Telltales.top.pt)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .overlay(alignment: .top) {
                Text(DesignSpec.DemoBadge.text)
                    .font(DriveFont.cjk(DesignSpec.DemoBadge.fontSize.pt))
                    .tracking(1.4)
                    .foregroundStyle(Color(rgb: 0x3A2A10))
                    .padding(.top, DesignSpec.DemoBadge.paddingTop.pt)
                    .padding(.bottom, DesignSpec.DemoBadge.paddingBottom.pt)
                    .padding(.horizontal, DesignSpec.DemoBadge.paddingLeading.pt)
                    .background(DriveColor.caution)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSpec.DemoBadge.cornerRadius.pt))
                    .padding(.top, DesignSpec.DemoBadge.top.pt)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .overlay(alignment: .topTrailing) {
                HStack(spacing: DesignSpec.TopRight.gap.pt) {
                    Circle().fill(statusColor).frame(width: DesignSpec.TopRight.dot.pt, height: DesignSpec.TopRight.dot.pt).opacity(0.95)
                    Text(model.link.statusDetail)
                        .font(DriveFont.cjk(11))
                        .foregroundStyle(DriveColor.secondary)
                        .lineLimit(1)
                    if model.link.isStale {
                        Text("已冻结")
                            .font(DriveFont.cjk(8))
                            .foregroundStyle(DriveColor.caution)
                    }
                }
                .padding(.top, DesignSpec.TopRight.top.pt)
                .padding(.trailing, clearance.statusRight.pt)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            .overlay(alignment: .topTrailing) {
                Button(action: { if interactive { onSettings(true) } }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(DriveColor.secondary)
                        .frame(width: DesignSpec.SettingsButton.side.pt, height: DesignSpec.SettingsButton.side.pt)
                }
                .buttonStyle(.plain)
                .disabled(!interactive)
                .padding(.top, DesignSpec.SettingsButton.top.pt)
                .padding(.trailing, clearance.gearRight.pt)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
    }

    private var statusColor: Color {
        switch model.link {
        case .simulated: return DriveColor.ok
        case .connecting: return DriveColor.cyan
        case .disconnected: return DriveColor.danger
        case .stale: return DriveColor.caution
        }
    }

    private var bottomChrome: some View {
        HStack(spacing: 12) {
            batteryIcon
            Text(model.link.showsLastReading ? "68%" : "--")
            Text(model.link.showsLastReading ? "312 km" : "")
            Text(model.link.showsLastReading ? "24°C" : "")
            if model.link.isStale {
                Text("过期").foregroundStyle(DriveColor.caution)
            }
            Spacer(minLength: 8)
            HStack(spacing: 10) {
                ForEach(["P", "R", "N", "D"], id: \.self) { gear in
                    Text(gear)
                        .foregroundStyle(gear == activeGear ? DriveColor.primary : DriveColor.tertiary.opacity(0.7))
                }
            }
            .font(DriveFont.medium(13))
            Spacer(minLength: 8)
            Text(model.link.showsLastReading ? "12486 km" : "")
            Text(model.link.showsLastReading ? (model.link.snapshot?.dateLabel ?? "") : "")
                .font(DriveFont.cjk(12))
            Text(model.link.showsLastReading ? (model.link.snapshot?.clockLabel ?? "") : "")
        }
        .font(DriveFont.regular(DesignSpec.BottomBar.fontSize.pt))
        .foregroundStyle(DriveColor.secondary)
        .opacity(model.link.isStale ? 0.78 : 1)
        .frame(width: DesignSpec.BottomBar.width.pt, height: DesignSpec.BottomBar.height.pt, alignment: .center)
        .position(
            x: DesignSpec.BottomBar.x.pt + DesignSpec.BottomBar.width.pt / 2,
            y: DesignSpec.BottomBar.y.pt + DesignSpec.BottomBar.height.pt / 2
        )
    }

    private var activeGear: String {
        guard model.link.showsLastReading, let gear = model.link.snapshot?.gear else { return "" }
        return gear.rawValue
    }

    private var batteryIcon: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .stroke(DriveColor.secondary, lineWidth: 1)
                .frame(width: 22, height: 10)
            RoundedRectangle(cornerRadius: 1)
                .fill(model.link.showsLastReading ? DriveColor.ok : Color.clear)
                .frame(width: model.link.showsLastReading ? 14 : 0, height: 6)
                .padding(.leading, 2)
        }
    }

    private var settingsSheet: some View {
        ZStack {
            Color.black.opacity(0.62)
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("仪表主题")
                        .font(DriveFont.cjk(16))
                        .tracking(2)
                        .foregroundStyle(DriveColor.primary)
                    Spacer()
                    Button("关闭") { onSettings(false) }
                        .buttonStyle(.plain)
                        .font(DriveFont.cjk(13))
                        .foregroundStyle(DriveColor.secondary)
                        .disabled(!interactive)
                }
                if let reason = ThemePolicy.blockReason(parked: model.parked) {
                    Text(reason)
                        .font(DriveFont.cjk(12))
                        .foregroundStyle(DriveColor.caution)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text("停车时可切换整套仪表。全部数值为演示数据，不代表真实车辆或蓝牙已经连上。")
                    .font(DriveFont.cjk(11))
                    .foregroundStyle(DriveColor.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 10) {
                    themeCard(.digital, "简洁数字", "左右大数字，中间内容")
                    themeCard(.dualDial, "双圆盘", "左右弧线仪表，中间内容")
                    themeCard(.centralDial, "中央大圆", "左地图，中车速，右导航或音乐")
                }
                Text(Copy.artNote)
                    .font(DriveFont.cjk(10))
                    .foregroundStyle(DriveColor.tertiary)
                HStack {
                    Button("状态总览") { onOpenGallery() }
                    Spacer()
                    Button(model.parked ? "标为行驶" : "标为停车") {
                        onScenario(model.parked ? .driving : .parked)
                    }
                }
                .buttonStyle(.plain)
                .font(DriveFont.cjk(13))
                .foregroundStyle(DriveColor.ok)
                .disabled(!interactive)
            }
            .padding(22)
            .frame(width: 640)
            .background(
                LinearGradient(
                    colors: [Color(red: 18 / 255, green: 25 / 255, blue: 36 / 255), Color(red: 11 / 255, green: 16 / 255, blue: 24 / 255)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.14), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    private func themeCard(_ theme: ClusterTheme, _ title: String, _ detail: String) -> some View {
        Button(action: { if interactive { onTheme(theme) } }) {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(DriveColor.background)
                    .frame(height: 52)
                    .overlay(Text(title.prefix(2)).font(DriveFont.figure(16)).foregroundStyle(DriveColor.primary))
                Text(title).font(DriveFont.cjk(13)).foregroundStyle(DriveColor.primary)
                Text(detail).font(DriveFont.cjk(10)).foregroundStyle(DriveColor.tertiary)
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(model.theme == theme ? Color.white.opacity(0.62) : DriveColor.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!interactive || !model.parked)
        .opacity(model.parked ? 1 : 0.4)
    }
}

struct SvgText: View {
    var text: String
    var font: Font
    var color: Color
    var tracking: CGFloat
    var x: CGFloat
    var baseline: CGFloat
    var opacity: Double = 1
    var marker: String? = nil

    var body: some View {
        Text(text)
            .font(font)
            .tracking(tracking)
            .foregroundStyle(color)
            .opacity(opacity)
            .fixedSize()
            .accessibilityIdentifier(marker ?? text)
            .alignmentGuide(.leading) { d in d.width / 2 - x }
            .alignmentGuide(.top) { d in d[.firstTextBaseline] - baseline }
    }
}

struct TelltaleRow: View {
    var body: some View {
        HStack(spacing: DesignSpec.Telltales.gap.pt) {
            TelltaleIcon(kind: .lamp, on: true)
            TelltaleIcon(kind: .belt, on: false)
            TelltaleIcon(kind: .wheel, on: false)
            TelltaleIcon(kind: .fan, on: false)
            TelltaleIcon(kind: .tire, on: false)
        }
    }
}

struct TelltaleIcon: View {
    enum Kind { case lamp, belt, wheel, fan, tire }
    var kind: Kind
    var on: Bool

    var body: some View {
        Canvas { context, _ in
            let color = on
                ? Color(rgb: 0x3EE0A4)
                : Color(red: 210 / 255, green: 218 / 255, blue: 228 / 255).opacity(0.55)
            let width: CGFloat = kind == .lamp || kind == .belt ? 1.35 : 1.3
            let style = StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round)
            for path in paths {
                context.stroke(path, with: .color(color), style: style)
            }
        }
        .frame(width: DesignSpec.Telltales.icon.pt, height: DesignSpec.Telltales.icon.pt)
        .accessibilityHidden(true)
    }

    private var paths: [Path] {
        switch kind {
        case .lamp:
            return [lampOuter, lampInner, lampRays]
        case .belt:
            return [circle(cx: 8, cy: 3.4, r: 1.5), beltBody, horizontal(3.2, 12.8, 9.4)]
        case .wheel:
            return [circle(cx: 8, cy: 8, r: 5.6), circle(cx: 8, cy: 8, r: 1.5), wheelSpokes]
        case .fan:
            return [circle(cx: 8, cy: 8, r: 1.3), fanA, fanB, fanC]
        case .tire:
            return [tireBody, tireStem]
        }
    }

    private var lampOuter: Path {
        var path = Path()
        path.move(to: CGPoint(x: 9, y: 3.6))
        path.addCurve(to: CGPoint(x: 13.2, y: 9.2), control1: CGPoint(x: 11.6, y: 4.7), control2: CGPoint(x: 13.2, y: 6.8))
        path.addCurve(to: CGPoint(x: 9, y: 14.8), control1: CGPoint(x: 13.2, y: 11.6), control2: CGPoint(x: 11.6, y: 13.7))
        return path
    }

    private var lampInner: Path {
        var path = Path()
        path.move(to: CGPoint(x: 9, y: 3.6))
        path.addCurve(to: CGPoint(x: 6, y: 9.2), control1: CGPoint(x: 7.2, y: 4.4), control2: CGPoint(x: 6, y: 6.2))
        path.addCurve(to: CGPoint(x: 9, y: 14.8), control1: CGPoint(x: 6, y: 12.2), control2: CGPoint(x: 7.2, y: 14))
        return path
    }

    private var lampRays: Path {
        var path = Path()
        path.move(to: CGPoint(x: 5, y: 5.2)); path.addLine(to: CGPoint(x: 2.4, y: 5.2))
        path.move(to: CGPoint(x: 5, y: 8)); path.addLine(to: CGPoint(x: 2.2, y: 8))
        path.move(to: CGPoint(x: 5, y: 10.8)); path.addLine(to: CGPoint(x: 2.4, y: 10.8))
        return path
    }

    private var beltBody: Path {
        var path = Path()
        path.move(to: CGPoint(x: 4.2, y: 13.6))
        path.addLine(to: CGPoint(x: 6.2, y: 6.4))
        path.addLine(to: CGPoint(x: 9.8, y: 6.4))
        path.addLine(to: CGPoint(x: 11.8, y: 13.6))
        return path
    }

    private var wheelSpokes: Path {
        var path = Path()
        path.move(to: CGPoint(x: 8, y: 2.4)); path.addLine(to: CGPoint(x: 8, y: 6.4))
        path.move(to: CGPoint(x: 3.3, y: 10.2)); path.addLine(to: CGPoint(x: 6.6, y: 8.6))
        path.move(to: CGPoint(x: 12.7, y: 10.2)); path.addLine(to: CGPoint(x: 9.4, y: 8.6))
        return path
    }

    private var fanA: Path {
        curve(8, 6.5, 9.8, 2.2, 13, 4.2, 11.4, 7.2)
    }

    private var fanB: Path {
        curve(9.2, 8.8, 13.2, 10.2, 11.6, 13.6, 8.6, 11.6)
    }

    private var fanC: Path {
        curve(7, 9, 3.2, 10.8, 2.6, 6.8, 6.2, 6.8)
    }

    private var tireBody: Path {
        Path(roundedRect: CGRect(x: 3.2, y: 4.2, width: 9.6, height: 8.2), cornerRadius: 3.2)
    }

    private var tireStem: Path {
        var path = Path()
        path.move(to: CGPoint(x: 6.2, y: 4.2))
        path.addLine(to: CGPoint(x: 6.2, y: 2.8))
        path.addLine(to: CGPoint(x: 9.8, y: 2.8))
        path.addLine(to: CGPoint(x: 9.8, y: 4.2))
        return path
    }

    private func circle(cx: CGFloat, cy: CGFloat, r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2))
    }

    private func horizontal(_ x1: CGFloat, _ x2: CGFloat, _ y: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: x1, y: y))
        path.addLine(to: CGPoint(x: x2, y: y))
        return path
    }

    private func line(_ x1: CGFloat, _ y1: CGFloat, _ x2: CGFloat, _ y2: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: x1, y: y1))
        path.addLine(to: CGPoint(x: x2, y: y2))
        return path
    }

    private func curve(_ x: CGFloat, _ y: CGFloat, _ c1x: CGFloat, _ c1y: CGFloat, _ c2x: CGFloat, _ c2y: CGFloat, _ ex: CGFloat, _ ey: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: x, y: y))
        path.addCurve(to: CGPoint(x: ex, y: ey), control1: CGPoint(x: c1x, y: c1y), control2: CGPoint(x: c2x, y: c2y))
        return path
    }
}

private struct RoadTrapezoid: View {
    var body: some View {
        Canvas { context, size in
            let sx = size.width / DesignSpec.Road.width.pt
            let sy = size.height / DesignSpec.Road.height.pt
            func map(_ point: BoardPoint) -> CGPoint {
                CGPoint(x: point.x.pt * sx, y: point.y.pt * sy)
            }
            var fill = Path()
            let corners = RoadOutline.fillCorners()
            if let first = corners.first {
                fill.move(to: map(first))
                for point in corners.dropFirst() {
                    fill.addLine(to: map(point))
                }
            }
            context.fill(
                fill,
                with: .linearGradient(
                    Gradient(stops: [
                        .init(color: Color(rgb: 0x0A0F16).opacity(0.15), location: 0),
                        .init(color: Color(rgb: 0x0A0F16).opacity(0.9), location: 1)
                    ]),
                    startPoint: CGPoint(x: size.width / 2, y: 0),
                    endPoint: CGPoint(x: size.width / 2, y: size.height)
                )
            )
            let ink = Color(red: 210 / 255, green: 220 / 255, blue: 235 / 255)
            for stroke in RoadOutline.strokes() where !stroke.closed {
                var path = Path()
                guard let first = stroke.points.first else { continue }
                path.move(to: map(first))
                for point in stroke.points.dropFirst() {
                    path.addLine(to: map(point))
                }
                context.stroke(
                    path,
                    with: .color(ink.opacity(stroke.dashed ? 0.26 : 0.22)),
                    style: StrokeStyle(
                        lineWidth: (stroke.dashed ? DesignSpec.Road.centerStroke : DesignSpec.Road.edgeStroke).pt,
                        lineCap: .round,
                        dash: stroke.dashed ? [DesignSpec.Road.dash.pt, DesignSpec.Road.dashGap.pt] : []
                    )
                )
            }
        }
    }
}
