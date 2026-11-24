import XCTest
@testable import DriveDialCore

final class DesignSpecTests: XCTestCase {
    func testArtboardAndSafeMarginsMatchTheHtml() {
        XCTAssertEqual(DesignSpec.artboardWidth, 874)
        XCTAssertEqual(DesignSpec.artboardHeight, 402)
        XCTAssertEqual(DesignBoard.reservedLeading, 59)
        XCTAssertEqual(DesignBoard.reservedTrailing, 59)
        XCTAssertEqual(DesignBoard.reservedBottom, 21)
    }

    func testCleanHeroUsesBaselineAndUnsignedPower() {
        XCTAssertEqual(DesignSpec.CleanHero.fontSize, 134.24)
        XCTAssertEqual(DesignSpec.CleanHero.fontWeight, 200)
        XCTAssertEqual(DesignSpec.CleanHero.letterSpacing, -2.8)
        XCTAssertEqual(DesignSpec.CleanHero.speedX, 149.37)
        XCTAssertEqual(DesignSpec.CleanHero.powerX, 721.22)
        XCTAssertEqual(DesignSpec.CleanHero.baselineY, 244.62)
        XCTAssertEqual(DesignSpec.CleanHero.visualCenterY, 198.92)
        XCTAssertEqual(DesignSpec.CleanHero.speedText, "36")
        XCTAssertEqual(DesignSpec.CleanHero.powerText, "12")
        XCTAssertFalse(DesignSpec.CleanHero.powerText.contains("+"))
        XCTAssertEqual(DesignSpec.wholeHero(12), "12")
        XCTAssertFalse(DesignSpec.wholeHero(12).contains("+"))
        XCTAssertFalse(DesignSpec.CleanHero.drawsUnderline)
        XCTAssertEqual(DesignSpec.CleanHero.labelY, 74.91)
        XCTAssertEqual(DesignSpec.CleanHero.unitY, 262.17)
        XCTAssertGreaterThan(DesignSpec.CleanHero.unitY, DesignSpec.CleanHero.baselineY)
        XCTAssertEqual(DesignSpec.CleanHero.unitSize, 12)
    }

    func testSingleCenterGlowIsNotTwoSideBlobs() {
        XCTAssertEqual(DesignSpec.Background.ellipseCX, 437)
        XCTAssertEqual(DesignSpec.Background.ellipseCY, 210)
        XCTAssertEqual(DesignSpec.Background.ellipseRX, 390)
        XCTAssertEqual(DesignSpec.Background.ellipseRY, 165)
        XCTAssertEqual(DesignSpec.Background.glowCenterOpacity, 0.55)
        XCTAssertEqual(DesignSpec.Background.glowMidOffset, 0.40)
        XCTAssertEqual(DesignSpec.Background.glowEdgeOpacity, 0)
        XCTAssertEqual(DesignSpec.Background.gradientMiddleOffset, 0.55)
    }

    func testCarRoadDotsAndBottomBar() {
        XCTAssertEqual(DesignSpec.RearCar.x, 406.37)
        XCTAssertEqual(DesignSpec.RearCar.y, 216.05)
        XCTAssertEqual(DesignSpec.RearCar.width, 60.41)
        XCTAssertEqual(DesignSpec.RearCar.height, 83.23)
        XCTAssertEqual(DesignSpec.rearHeightFraction, 0.207, accuracy: 0.001)
        XCTAssertEqual(DesignSpec.RearCar.width / DesignSpec.RearCar.height, 630.0 / 868.0, accuracy: 0.002)
        XCTAssertEqual(DesignSpec.Road.x, 350.79)
        XCTAssertEqual(DesignSpec.Road.y, 137.81)
        XCTAssertEqual(DesignSpec.Road.width, 172.41)
        XCTAssertEqual(DesignSpec.Road.height, 213.90)
        XCTAssertEqual(DesignSpec.dotsBottomEdgeY, 338)
        XCTAssertEqual(DesignSpec.Dots.bottom, 64)
        XCTAssertEqual(DesignSpec.BottomBar.x, 59)
        XCTAssertEqual(DesignSpec.BottomBar.y, 364)
        XCTAssertEqual(DesignSpec.BottomBar.width, 756)
        XCTAssertEqual(DesignSpec.BottomBar.height, 22)
        XCTAssertEqual(DesignSpec.Arrows.previousLeft, 268)
        XCTAssertEqual(DesignSpec.Arrows.nextLeft, 562)
        XCTAssertEqual(DesignSpec.Arrows.side, 44)
        XCTAssertEqual(DesignSpec.arrowCenterY, 210)
    }

    func testCenterGroupLiftsTwelvePointsWithoutResizingOrClipping() {
        XCTAssertEqual(CenterGroup.lift, 12)
        XCTAssertEqual(DesignBoard.rearCar.y, CenterGroup.Source.rearCar.y - 12, accuracy: 0.001)
        XCTAssertEqual(DesignBoard.dualCar.y, CenterGroup.Source.dualCar.y - 12, accuracy: 0.001)
        XCTAssertEqual(DesignBoard.topCar.y, CenterGroup.Source.topCar.y - 12, accuracy: 0.001)
        XCTAssertEqual(DesignBoard.road.y, CenterGroup.Source.road.y - 12, accuracy: 0.001)
        XCTAssertEqual(DesignBoard.rearCar.width, CenterGroup.Source.rearCar.width)
        XCTAssertEqual(DesignBoard.rearCar.height, CenterGroup.Source.rearCar.height)
        XCTAssertEqual(DesignBoard.dualCar.width, CenterGroup.Source.dualCar.width)
        XCTAssertEqual(DesignBoard.dualCar.height, CenterGroup.Source.dualCar.height)
        XCTAssertEqual(DesignBoard.topCar.width, CenterGroup.Source.topCar.width)
        XCTAssertEqual(DesignBoard.topCar.height, CenterGroup.Source.topCar.height)
        XCTAssertEqual(DesignBoard.road.width, CenterGroup.Source.road.width)
        XCTAssertEqual(DesignBoard.road.height, CenterGroup.Source.road.height)
        XCTAssertEqual(DesignBoard.road.x, CenterGroup.Source.road.x)

        XCTAssertEqual(CenterStrip.originY, 128)
        XCTAssertEqual(CenterStrip.height, 224)
        XCTAssertEqual(CenterStrip.width, 250)
        XCTAssertEqual(CenterStrip.originX, 312)
        let strip = LayoutRect(x: CenterStrip.originX, y: CenterStrip.originY, width: CenterStrip.width, height: CenterStrip.height)
        let pages = [
            (DesignBoard.road, CenterGroup.Source.road),
            (DesignBoard.rearCar, CenterGroup.Source.rearCar),
            (DesignBoard.dualCar, CenterGroup.Source.dualCar),
            (DesignBoard.topCar, CenterGroup.Source.topCar)
        ]
        for (placed, source) in pages {
            XCTAssertTrue(strip.contains(CenterGroup.layoutRect(placed)))
            XCTAssertEqual(placed.y - strip.minY, source.y - CenterGroup.Source.stripOriginY, accuracy: 0.001)
            XCTAssertEqual(placed.width, source.width)
            XCTAssertEqual(placed.height, source.height)
            XCTAssertEqual(placed.x, source.x)
        }

        XCTAssertEqual(CenterGroup.tripCenter.y, 213)
        XCTAssertEqual(CenterGroup.tripCenter.y - CenterStrip.originY, CenterGroup.Source.tripCenterY - CenterGroup.Source.stripOriginY)
        XCTAssertEqual(CenterGroup.tireSpots.map(\.y), [170, 170, 240, 240])
        for spot in CenterGroup.tireSpots {
            let label = LayoutRect(x: spot.x - 30, y: spot.y - 22, width: 60, height: 44)
            XCTAssertTrue(strip.contains(label))
        }
        let trip = LayoutRect(x: CenterGroup.tripCenter.x - 125, y: CenterGroup.tripCenter.y - 70, width: 250, height: 140)
        XCTAssertTrue(strip.contains(trip))

        XCTAssertEqual(DesignSpec.dotsBottomEdgeY, 402 - 64)
        XCTAssertLessThan(DesignSpec.dotsBottomEdgeY, DesignSpec.BottomBar.y)
        XCTAssertLessThan(DesignBoard.road.y + DesignBoard.road.height, DesignSpec.BottomBar.y)
        XCTAssertGreaterThan(DesignBoard.road.y, DesignSpec.CleanHero.labelY)
        XCTAssertEqual(DesignSpec.CleanHero.baselineY, 244.62)
        XCTAssertEqual(DesignSpec.CleanHero.speedX, 149.37)
        XCTAssertEqual(DesignSpec.CleanHero.powerX, 721.22)
        let sourceArrowCenter = CenterGroup.Source.arrowTop + DesignSpec.Arrows.side / 2
        XCTAssertEqual(DesignSpec.arrowCenterY, sourceArrowCenter - CenterGroup.lift)
        XCTAssertEqual(
            DesignSpec.arrowCenterY - DesignBoard.rearCar.midY,
            sourceArrowCenter - CenterGroup.Source.rearCar.midY,
            accuracy: 0.001
        )
    }

    func testRoadStrokeIsTwoOpenSlantsAndADash() {
        let strokes = RoadOutline.strokes()
        XCTAssertEqual(strokes.count, 3)
        XCTAssertEqual(strokes.filter { !$0.dashed }.count, 2)
        XCTAssertEqual(strokes.filter(\.dashed).count, 1)
        XCTAssertTrue(strokes.allSatisfy { $0.closed == false && $0.points.count == 2 && !$0.isHorizontal })
        let edges = strokes.filter { !$0.dashed }
        XCTAssertEqual(edges[0].points[0].x, DesignSpec.Road.topLeftX)
        XCTAssertEqual(edges[1].points[0].x, DesignSpec.Road.topRightX)
        XCTAssertEqual(edges[0].points[0].y, 0)
        XCTAssertEqual(edges[1].points[0].y, 0)
        XCTAssertNotEqual(edges[0].points[0].x, edges[1].points[0].x)
        XCTAssertEqual(edges[0].points[1].x, 0)
        XCTAssertEqual(edges[1].points[1].x, DesignSpec.Road.width)
        XCTAssertEqual(edges[0].points[1].y, DesignSpec.Road.height)
        XCTAssertEqual(edges[1].points[1].y, DesignSpec.Road.height)
        let dash = strokes.first { $0.dashed }!
        XCTAssertEqual(dash.points[0].x, dash.points[1].x)
        XCTAssertEqual(dash.points[0].y, DesignSpec.Road.centerLocalY1)
        XCTAssertEqual(dash.points[1].y, DesignSpec.Road.centerLocalY2)
        let corners = RoadOutline.fillCorners()
        XCTAssertEqual(corners.count, 4)
        XCTAssertFalse(strokes.contains { stroke in
            let xs = stroke.points.map(\.x)
            return xs.contains(DesignSpec.Road.topLeftX) && xs.contains(DesignSpec.Road.topRightX)
        })
    }

    func testReadyLabelIsNotTheDemoCapsule() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let live = DemoScript.link(scenario: .parked, clock: DemoClock(), now: now)
        XCTAssertEqual(live.readyLabel, "READY")
        XCTAssertEqual(live.disclosure, "演示模式")
        XCTAssertEqual(DesignSpec.Ready.left, 58.89)
        XCTAssertEqual(DesignSpec.Ready.top, 22)
        XCTAssertEqual(DesignSpec.Telltales.count, 5)
        XCTAssertEqual(DesignSpec.Telltales.left, 128)
        XCTAssertNotEqual(live.readyLabel, DesignSpec.DemoBadge.text)
    }

    func testGlyphFramePutsTheBaselineOnTheDesignLine() {
        let frame = GlyphFrameLayout.centeredOnBaseline(
            centerX: DesignSpec.CleanHero.speedX,
            baselineY: DesignSpec.CleanHero.baselineY,
            width: 180,
            height: 160,
            baselineFromTop: 110
        )
        XCTAssertEqual(frame.minY + 110, DesignSpec.CleanHero.baselineY, accuracy: 0.001)
        XCTAssertEqual(frame.centerX, DesignSpec.CleanHero.speedX, accuracy: 0.001)
        XCTAssertLessThan(frame.maxY, DesignSpec.BottomBar.y)
        XCTAssertLessThan(DesignSpec.CleanHero.unitY, DesignSpec.BottomBar.y)
        let topPlacedAtBaseline = DesignSpec.CleanHero.baselineY
        XCTAssertGreaterThan(topPlacedAtBaseline + 130, DesignSpec.BottomBar.y)
    }

    func testScreenMappingScalesADesignPointOnce() {
        let placed = PlacedBoard.place(canvas: LayoutSize(width: 956, height: 440), safe: .zero)
        let point = BoardTransform.screen(
            BoardPoint(x: DesignSpec.CleanHero.speedX, y: DesignSpec.CleanHero.baselineY),
            placed: placed
        )
        XCTAssertEqual(point.x, placed.originX + DesignSpec.CleanHero.speedX * placed.scale, accuracy: 0.01)
        XCTAssertEqual(point.y, placed.originY + DesignSpec.CleanHero.baselineY * placed.scale, accuracy: 0.01)
        XCTAssertEqual(placed.scale, 956 / 874, accuracy: 0.0001)
    }

    func testGearStaysInsideARealTrailingInset() {
        let open = ChromeClearanceLayout.place(safeLeading: 0, safeTrailing: 0, scale: 1)
        XCTAssertEqual(open.gearRight, 10, accuracy: 0.001)
        XCTAssertEqual(open.statusRight, 56, accuracy: 0.001)
        XCTAssertEqual(open.readyLeft, 58.89, accuracy: 0.001)
        XCTAssertEqual(open.telltaleLeft, 128, accuracy: 0.001)

        let island = ChromeClearanceLayout.place(safeLeading: 0, safeTrailing: 59, scale: 1)
        XCTAssertEqual(island.gearRight, 59, accuracy: 0.001)
        XCTAssertGreaterThanOrEqual(island.statusRight, island.gearRight + 44)
    }

    func testReferencePhoneDoesNotDoubleCountTheDesignMargin() {
        let placed = PlacedBoard.place(
            canvas: LayoutSize(width: 874, height: 402),
            safe: LayoutInsets(top: 0, leading: 59, bottom: 21, trailing: 59)
        )
        XCTAssertEqual(placed.scale, 1, accuracy: 0.0001)
        XCTAssertEqual(placed.originX, 0, accuracy: 0.01)
        XCTAssertEqual(placed.originY, 0, accuracy: 0.01)
    }
}
