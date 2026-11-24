import XCTest
@testable import DriveDialCore

final class ThemePolicyTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    func testThemeChangesOnlyWhileParkedAndLive() {
        XCTAssertNil(ThemePolicy.blockReason(parked: true))
        XCTAssertEqual(ThemePolicy.change(to: .dualDial, parked: true), .updated(.dualDial))
        XCTAssertEqual(
            ThemePolicy.change(to: .centralDial, parked: false),
            .blocked(Copy.themeBlockedWhileMoving)
        )
        XCTAssertTrue(DemoScenario.parked.isParked)
        XCTAssertFalse(DemoScenario.driving.isParked)
        XCTAssertTrue(DemoScenario.disconnected.isParked)
    }

    func testSessionDoesNotMutateThemeWhenBlocked() {
        let session = DemoSession(scenario: .driving, theme: .digital, parked: false)
        let result = session.setTheme(.dualDial, now: now)
        XCTAssertEqual(result, .blocked(Copy.themeBlockedWhileMoving))
        XCTAssertEqual(session.theme, .digital)

        session.setScenario(.parked)
        XCTAssertEqual(session.setTheme(.centralDial, now: now), .updated(.centralDial))
        XCTAssertEqual(session.theme, .centralDial)
    }

    func testPreferenceRoundTrip() {
        let defaults = UserDefaults(suiteName: "DriveDialThemeTests")!
        defaults.removePersistentDomain(forName: "DriveDialThemeTests")
        XCTAssertEqual(ThemePreference.load(from: defaults), .digital)
        ThemePreference.save(.dualDial, to: defaults)
        XCTAssertEqual(ThemePreference.load(from: defaults), .dualDial)
        defaults.set("nope", forKey: ThemePreference.defaultsKey)
        XCTAssertEqual(ThemePreference.load(from: defaults), .digital)
    }

    func testGalleryApplyStillObeysThemeLock() {
        let session = DemoSession(scenario: .parked, theme: .digital)
        let drivingDial = GalleryCatalog.pages().first { $0.id == "settings-driving" }!
        session.setTheme(.dualDial, now: now)
        let result = session.apply(page: drivingDial, now: now)
        XCTAssertEqual(result, .blocked(Copy.themeBlockedWhileMoving))
        XCTAssertEqual(session.theme, .dualDial)
        XCTAssertEqual(session.scenario, .driving)
        XCTAssertFalse(session.parked)
        XCTAssertTrue(session.settingsOpen)
    }
}

final class LinkStateTests: XCTestCase {
    func testDisclosuresNeverClaimALiveBluetoothLink() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let states: [LinkState] = DemoScenario.allCases.map {
            DemoScript.link(scenario: $0, clock: DemoClock(elapsed: 8), now: now)
        }
        for state in states {
            XCTAssertFalse(state.presentsBluetoothAsConnected)
            XCTAssertFalse(state.disclosure.contains("已连接"))
            XCTAssertTrue(
                state.disclosure.contains("演示")
                    || state.disclosure.contains("断开")
                    || state.disclosure.contains("连接")
                    || state.disclosure.contains("过期")
            )
        }
    }

    func testDisconnectedHidesReadingsAndStaleKeepsTheLastOnes() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let disconnected = DemoScript.link(scenario: .disconnected, clock: DemoClock(), now: now)
        XCTAssertNil(disconnected.snapshot)
        XCTAssertFalse(disconnected.showsLastReading)

        let stale = DemoScript.link(scenario: .stale, clock: DemoClock(), now: now)
        XCTAssertEqual(stale.disclosure, "数据已过期")
        XCTAssertEqual(stale.snapshot?.capturedAt, now.addingTimeInterval(-42))
        XCTAssertTrue(stale.showsLastReading)
        XCTAssertFalse(stale.isLiveSimulation)
    }

    func testProviderProtocolIsTheReadOnlySurface() {
        let session = DemoSession()
        let provider: VehicleDataProvider = session
        let link = provider.current(now: Date(timeIntervalSince1970: 10))
        XCTAssertTrue(link.isLiveSimulation)
        XCTAssertEqual(link.snapshot?.gear, .drive)
        XCTAssertEqual(link.snapshot?.isSimulated, true)
    }
}
