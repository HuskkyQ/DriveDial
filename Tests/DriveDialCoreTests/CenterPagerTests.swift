import XCTest
@testable import DriveDialCore

final class CenterPagerTests: XCTestCase {
    func testPagesAreCarTiresThenTrip() {
        XCTAssertEqual(CenterPagerState.pages, [.car, .tires, .trip])
        XCTAssertEqual(CenterStrip.originX, 312)
        XCTAssertEqual(CenterStrip.width, 250)
        XCTAssertEqual(CenterStrip.maxX, 562)
        XCTAssertLessThan(DesignSpec.CleanHero.speedX, CenterStrip.originX)
        XCTAssertGreaterThan(DesignSpec.CleanHero.powerX, CenterStrip.maxX)
    }

    func testArrowsStopAtTheEnds() {
        var pager = CenterPagerState(module: .car)
        XCTAssertFalse(pager.canRetreat)
        XCTAssertTrue(pager.canAdvance)
        XCTAssertFalse(pager.move(-1))
        XCTAssertEqual(pager.module, .car)

        XCTAssertTrue(pager.move(1))
        XCTAssertEqual(pager.module, .tires)
        XCTAssertTrue(pager.move(1))
        XCTAssertEqual(pager.module, .trip)
        XCTAssertFalse(pager.canAdvance)
        XCTAssertFalse(pager.move(1))
        XCTAssertEqual(pager.index, 2)
    }

    func testDragCommitsOnePageAndDoesNotWrap() {
        var pager = CenterPagerState(module: .car)
        XCTAssertFalse(pager.settle(translation: -20, pageWidth: 250))
        XCTAssertEqual(pager.index, 0)
        XCTAssertTrue(pager.settle(translation: -80, pageWidth: 250))
        XCTAssertEqual(pager.module, .tires)

        pager = CenterPagerState(module: .trip)
        XCTAssertFalse(pager.settle(translation: -200, pageWidth: 250))
        XCTAssertEqual(pager.module, .trip)
        XCTAssertTrue(pager.settle(translation: 80, pageWidth: 250))
        XCTAssertEqual(pager.module, .tires)
    }

    func testEdgeDragIsResistedButStillBounded() {
        let start = CenterPagerState(module: .car)
        XCTAssertEqual(start.resistedTranslation(80), 20)
        XCTAssertEqual(start.resistedTranslation(-80), -80)
        let end = CenterPagerState(module: .trip)
        XCTAssertEqual(end.resistedTranslation(-40), -10)
        XCTAssertEqual(end.selectedDot, 2)
    }
}
