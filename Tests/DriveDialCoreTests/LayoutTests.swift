import XCTest
@testable import DriveDialCore

final class ClusterLayoutTests: XCTestCase {
    func testRearCarMatchesTheV6Box() {
        XCTAssertEqual(DesignBoard.rearCar.width, 60.41, accuracy: 0.001)
        XCTAssertEqual(DesignBoard.rearCar.height, 83.23, accuracy: 0.001)
        XCTAssertEqual(DesignBoard.rearHeightFraction, 0.207, accuracy: 0.001)
        XCTAssertEqual(
            DesignBoard.rearCar.width / DesignBoard.rearCar.height,
            DesignBoard.rearPixelSize.width / DesignBoard.rearPixelSize.height,
            accuracy: 0.002
        )
        XCTAssertEqual(
            DesignBoard.topCar.width / DesignBoard.topCar.height,
            DesignBoard.topPixelSize.width / DesignBoard.topPixelSize.height,
            accuracy: 0.002
        )
        XCTAssertEqual(DesignBoard.rearPixelSize, LayoutSize(width: 630, height: 868))
        XCTAssertEqual(DesignBoard.topPixelSize, LayoutSize(width: 626, height: 1004))
    }

    func testReferenceBoardIsIdentity() {
        let placed = PlacedBoard.place(canvas: LayoutSize(width: 874, height: 402), safe: .zero)
        XCTAssertEqual(placed.scale, 1, accuracy: 0.0001)
        XCTAssertEqual(placed.originX, 0, accuracy: 0.01)
        XCTAssertEqual(placed.originY, 0, accuracy: 0.01)
    }

    func testDesignMarginsCoverTheReferenceIsland() {
        let placed = PlacedBoard.place(
            canvas: LayoutSize(width: 874, height: 402),
            safe: LayoutInsets(top: 0, leading: 59, bottom: 21, trailing: 59)
        )
        XCTAssertEqual(placed.scale, 1, accuracy: 0.0001)
        XCTAssertEqual(placed.originX, 0, accuracy: 0.01)
    }

    func testLargerInsetShrinksInsteadOfHardcodingAPhone() {
        let placed = PlacedBoard.place(
            canvas: LayoutSize(width: 874, height: 402),
            safe: LayoutInsets(top: 0, leading: 80, bottom: 21, trailing: 59)
        )
        XCTAssertLessThan(placed.scale, 1)
        XCTAssertGreaterThanOrEqual(placed.originX + 0.01, 80)
        let right = placed.originX + placed.boardWidth
        XCTAssertLessThanOrEqual(right, 874 - 59 + 0.01)
    }

    func testKnownCanvasesStayFinite() {
        let phones = [
            LayoutSize(width: 874, height: 402),
            LayoutSize(width: 956, height: 440),
            LayoutSize(width: 852, height: 393),
            LayoutSize(width: 667, height: 375)
        ]
        for canvas in phones {
            let placed = PlacedBoard.place(
                canvas: canvas,
                safe: LayoutInsets(top: 0, leading: 47, bottom: 21, trailing: 0)
            )
            XCTAssertGreaterThan(placed.scale, 0)
            XCTAssertFalse(placed.scale.isNaN)
            XCTAssertGreaterThanOrEqual(placed.originX + 0.01, 0)
        }
    }
}

final class AspectFitTests: XCTestCase {
    func testPreservesRatioInsideBox() {
        let fitted = AspectFit.size(
            container: LayoutSize(width: 60.41, height: 83.23),
            image: LayoutSize(width: 630, height: 868)
        )
        XCTAssertEqual(fitted.width / fitted.height, 630.0 / 868.0, accuracy: 0.0001)
        XCTAssertLessThanOrEqual(fitted.width, 60.41 + 0.01)
        XCTAssertLessThanOrEqual(fitted.height, 83.23 + 0.01)
    }

    func testTallImageIsLimitedByHeight() {
        let fitted = AspectFit.size(
            container: LayoutSize(width: 90, height: 40),
            image: LayoutSize(width: 30, height: 60)
        )
        XCTAssertEqual(fitted.height, 40, accuracy: 0.001)
        XCTAssertEqual(fitted.width, 20, accuracy: 0.001)
    }
}
