import XCTest
@testable import DriveDialCore

final class DemoScriptTests: XCTestCase {
    func testRampDistanceMatchesTheIntegral() {
        let atRampEnd = DriveKinematics.distanceKm(elapsed: 6)
        XCTAssertEqual(atRampEnd, 258.0 / 3600.0, accuracy: 0.00001)
        XCTAssertEqual(DriveKinematics.speedKmh(elapsed: 0), 0, accuracy: 0.001)
        XCTAssertEqual(DriveKinematics.speedKmh(elapsed: 6), 86, accuracy: 0.001)
        XCTAssertEqual(DriveKinematics.distanceKm(elapsed: 0), 0, accuracy: 0.00001)
        XCTAssertGreaterThan(DriveKinematics.distanceKm(elapsed: 20), atRampEnd)
    }

    func testParkThenDriveScript() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let parked = DemoScript.snapshot(.parked, elapsed: 30, now: now)
        XCTAssertEqual(parked.gear, .drive)
        XCTAssertEqual(parked.speedKmh, 36, accuracy: 0.001)
        XCTAssertEqual(parked.navigation?.street, "滨河大道")
        XCTAssertTrue(parked.isSimulated)
        XCTAssertTrue(DemoScenario.parked.isParked)

        let driving = DemoScript.snapshot(.driving, elapsed: 12, now: now)
        XCTAssertEqual(driving.gear, .drive)
        XCTAssertEqual(driving.speedKmh, 36, accuracy: 0.001)
        XCTAssertEqual(driving.powerKw, 12, accuracy: 0.001)
        XCTAssertEqual(driving.batteryPercent, 68, accuracy: 0.001)
        XCTAssertEqual(driving.navigation?.maneuver, "右转")
        XCTAssertEqual(driving.navigation?.street, "滨河大道")
        XCTAssertEqual(driving.navigation?.distanceMeters, 200)
        XCTAssertEqual(driving.navigation?.isSimulated, true)
        XCTAssertEqual(driving.trip.distanceKm, 12.4, accuracy: 0.001)
    }

    func testWarningScenarios() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let low = DemoScript.snapshot(.lowBattery, elapsed: 10, now: now)
        XCTAssertEqual(ReadoutToneRule.battery(low.batteryPercent), .caution)
        XCTAssertEqual(low.rangeKm, 24)

        let tires = DemoScript.snapshot(.tireWarning, elapsed: 10, now: now)
        XCTAssertEqual(tires.tires.frontLeft.tone, .caution)
        XCTAssertEqual(tires.tires.frontRight.tone, .ok)

        let reverse = DemoScript.snapshot(.reverse, elapsed: 3, now: now)
        XCTAssertEqual(reverse.gear, .reverse)
        XCTAssertNil(reverse.navigation)
        XCTAssertEqual(ReadoutToneRule.gear(reverse.gear), .caution)
    }

    func testPlaybackAdvancesOnlyWhilePlaying() {
        var clock = DemoClock(media: MediaState(isPlaying: false, progress: 0.2))
        clock = DemoScript.advance(clock, by: 18, scenario: .driving)
        XCTAssertEqual(clock.media.progress, 0.2, accuracy: 0.0001)
        XCTAssertEqual(clock.elapsed, 18, accuracy: 0.001)

        clock.media.isPlaying = true
        clock = DemoScript.advance(clock, by: 18, scenario: .parked)
        XCTAssertEqual(clock.elapsed, 18, accuracy: 0.001)
        XCTAssertEqual(clock.media.progress, 0.2 + 18 / MediaState.songDuration, accuracy: 0.0001)
    }

    func testParkedScenarioDoesNotAccumulateTrip() {
        let session = DemoSession(scenario: .parked)
        session.advance(by: 5)
        XCTAssertEqual(session.clock.elapsed, 0)
        session.setScenario(.driving)
        session.advance(by: 2)
        XCTAssertEqual(session.clock.elapsed, 2, accuracy: 0.001)
        session.togglePlayback()
        XCTAssertTrue(session.clock.media.isPlaying)
    }
}

final class FormattingTests: XCTestCase {
    func testReadingsUseStableDigits() {
        XCTAssertEqual(ReadoutFormat.speedKmh(86.4), "86")
        XCTAssertEqual(ReadoutFormat.bar(2.5), "2.5")
        XCTAssertEqual(ReadoutFormat.bar(1.84), "1.8")
        XCTAssertEqual(ReadoutFormat.percent(72.2), "72%")
        XCTAssertEqual(ReadoutFormat.kilowatts(12.2), "+12")
        XCTAssertEqual(ReadoutFormat.kilowatts(-3.4), "-3")
        XCTAssertEqual(ReadoutFormat.meters(300), "300 米")
        XCTAssertEqual(ReadoutFormat.duration(12 * 60), "12 分钟")
        XCTAssertEqual(ReadoutFormat.seconds(42), "42 秒")

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 8 * 3600)!
        let date = Date(timeIntervalSince1970: 0)
        XCTAssertEqual(ReadoutFormat.clock(date, calendar: calendar), "08:00")
    }

    func testPaletteIsBlackWhiteGreenOrange() {
        XCTAssertLessThan(DrivePalette.background.r, 0.05)
        XCTAssertLessThan(DrivePalette.background.g, 0.05)
        XCTAssertLessThan(DrivePalette.background.b, 0.08)
        XCTAssertGreaterThan(DrivePalette.ok.g, DrivePalette.ok.r)
        XCTAssertGreaterThan(DrivePalette.ok.g, DrivePalette.ok.b)
        XCTAssertGreaterThan(DrivePalette.caution.r, DrivePalette.caution.g)
        XCTAssertGreaterThan(DrivePalette.caution.g, DrivePalette.caution.b)
        XCTAssertEqual(ReadoutScale.powerFraction(0), 0.5, accuracy: 0.001)
        XCTAssertEqual(ReadoutScale.speedFraction(160), 1, accuracy: 0.001)
        XCTAssertEqual(ReadoutScale.speedFraction(-4), 0, accuracy: 0.001)
    }
}

final class GalleryCatalogTests: XCTestCase {
    func testCatalogCoversTheRequestedStatesWithoutEveryCombination() {
        let pages = GalleryCatalog.pages()
        XCTAssertEqual(Set(pages.map(\.id)).count, pages.count)
        XCTAssertEqual(pages.count, 18)
        XCTAssertLessThan(pages.count, 24)

        let themes = Set(pages.map(\.theme))
        XCTAssertEqual(themes, Set(ClusterTheme.allCases))
        XCTAssertTrue(pages.contains { $0.module == .car })
        XCTAssertTrue(pages.contains { $0.module == .tires })
        XCTAssertTrue(pages.contains { $0.module == .trip })
        XCTAssertTrue(pages.contains { $0.theme == .centralDial && $0.dialSide == .navigation })
        XCTAssertTrue(pages.contains { $0.theme == .centralDial && $0.dialSide == .media && $0.media.isPlaying })
        XCTAssertTrue(pages.contains { $0.theme == .centralDial && $0.dialSide == .media && !$0.media.isPlaying && !$0.media.isEmpty })
        XCTAssertTrue(pages.contains { $0.scenario == .disconnected })
        XCTAssertTrue(pages.contains { $0.scenario == .stale })
        XCTAssertTrue(pages.contains { $0.scenario == .connecting })

        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let locked = pages.first { $0.id == "settings-driving" }!.model(now: now)
        let open = pages.first { $0.id == "settings-parked" }!.model(now: now)
        XCTAssertEqual(ThemePolicy.blockReason(parked: locked.parked), Copy.themeBlockedWhileMoving)
        XCTAssertNil(ThemePolicy.blockReason(parked: open.parked))
        XCTAssertEqual(open.theme, .digital)
        let vehicle = pages.first { $0.id == "clean-vehicle" }!.model(now: now)
        XCTAssertEqual(vehicle.link.snapshot?.speedKmh, 36)

        let product = ClusterTheme.allCases.count
            * ClusterModule.allCases.count
            * ClusterScene.allCases.count
            * DemoScenario.allCases.count
        XCTAssertLessThan(pages.count, product)
    }

    func testChineseNames() {
        XCTAssertEqual(ClusterTheme.digital.title, "简洁数字")
        XCTAssertEqual(ClusterTheme.dualDial.title, "双圆盘")
        XCTAssertEqual(ClusterTheme.centralDial.title, "中央大圆")
        XCTAssertEqual(ClusterModule.car.title, "车模")
        XCTAssertEqual(ClusterModule.tires.title, "胎压")
        XCTAssertEqual(ClusterModule.trip.title, "行程")
        XCTAssertEqual(Gear.park.title, "停车")
        XCTAssertEqual(Copy.appName, "行仪")
    }
}
