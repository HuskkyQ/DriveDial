import XCTest

/// Runs on a Mac with Xcode. This cloud environment has no Xcode, so these cases are not executed here.
final class CenterPagerUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testCenterArrowsAdvanceDotsAndStopAtTheEnds() {
        let previous = app.buttons["center-previous"]
        let next = app.buttons["center-next"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        XCTAssertFalse(previous.isEnabled)
        XCTAssertEqual(app.otherElements["center-dot-0"].value as? String, "selected")

        next.tap()
        XCTAssertEqual(app.otherElements["center-dot-1"].value as? String, "selected")
        XCTAssertTrue(previous.isEnabled)

        next.tap()
        XCTAssertEqual(app.otherElements["center-dot-2"].value as? String, "selected")
        XCTAssertFalse(next.isEnabled)

        previous.tap()
        XCTAssertEqual(app.otherElements["center-dot-1"].value as? String, "selected")
        XCTAssertTrue(next.isEnabled)
    }

    func testSwipeLeftSelectsTheNextCenterPage() {
        let pager = app.otherElements["center-pager"]
        XCTAssertTrue(pager.waitForExistence(timeout: 5))
        pager.swipeLeft()
        XCTAssertEqual(app.otherElements["center-dot-1"].value as? String, "selected")
    }
}

final class CleanHeroUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testSpeedAndPowerStayOnOppositeSides() {
        let speed = app.staticTexts["hero-speed-value"]
        let power = app.staticTexts["hero-power-value"]
        let speedLabel = app.staticTexts["hero-speed-label"]
        let powerLabel = app.staticTexts["hero-power-label"]
        let speedUnit = app.staticTexts["hero-speed-unit"]
        let powerUnit = app.staticTexts["hero-power-unit"]
        XCTAssertTrue(speed.waitForExistence(timeout: 5))
        XCTAssertTrue(power.waitForExistence(timeout: 5))
        XCTAssertTrue(speedLabel.exists)
        XCTAssertTrue(powerLabel.exists)
        XCTAssertTrue(speedUnit.exists)
        XCTAssertTrue(powerUnit.exists)
        XCTAssertEqual(speed.label, "36")
        XCTAssertEqual(power.label, "12")
        XCTAssertEqual(speedLabel.label, "速度")
        XCTAssertEqual(powerLabel.label, "功率")
        XCTAssertEqual(speedUnit.label, "km/h")
        XCTAssertEqual(powerUnit.label, "kW")

        let midX = app.windows.element(boundBy: 0).frame.midX
        XCTAssertLessThan(speed.frame.midX, midX)
        XCTAssertGreaterThan(power.frame.midX, midX)
        XCTAssertGreaterThan(power.frame.minX, speed.frame.maxX)
        XCTAssertFalse(speed.frame.intersects(power.frame))
        XCTAssertFalse(speedLabel.frame.intersects(powerLabel.frame))
        XCTAssertFalse(speedUnit.frame.intersects(powerUnit.frame))
        assertSameColumn(speedLabel, speed)
        assertSameColumn(speedUnit, speed)
        assertSameColumn(powerLabel, power)
        assertSameColumn(powerUnit, power)
        XCTAssertLessThan(speedLabel.frame.midY, speed.frame.midY)
        XCTAssertGreaterThan(speedUnit.frame.midY, speed.frame.midY)
        XCTAssertLessThan(powerLabel.frame.midY, power.frame.midY)
        XCTAssertGreaterThan(powerUnit.frame.midY, power.frame.midY)
    }

    private func assertSameColumn(_ label: XCUIElement, _ value: XCUIElement) {
        XCTAssertEqual(label.frame.midX, value.frame.midX, accuracy: 30)
        XCTAssertLessThan(label.frame.midX, value.frame.maxX + 30)
        XCTAssertGreaterThan(label.frame.midX, value.frame.minX - 30)
    }
}
