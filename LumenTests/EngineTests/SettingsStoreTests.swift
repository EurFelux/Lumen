import XCTest
@testable import Lumen

final class SettingsStoreTests: XCTestCase {
    var store: SettingsStore!
    private var testSuiteName: String!
    private var testDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        testSuiteName = "test.SettingsStore.\(UUID().uuidString)"
        testDefaults = UserDefaults(suiteName: testSuiteName)!
        store = SettingsStore(defaults: testDefaults)
    }

    override func tearDown() {
        if let suiteName = testSuiteName {
            UserDefaults.standard.removePersistentDomain(forName: suiteName)
        }
        testSuiteName = nil
        testDefaults = nil
        store = nil
        super.tearDown()
    }

    func testDefaultLightThreshold() {
        XCTAssertEqual(store.lightThreshold, 400.0)
    }

    func testDefaultDebounceDuration() {
        XCTAssertEqual(store.debounceDuration, 5.0)
    }

    func testDefaultEnableAutoSwitch() {
        XCTAssertEqual(store.enableAutoSwitch, true)
    }

    func testDefaultLaunchAtLogin() {
        XCTAssertEqual(store.launchAtLogin, false)
    }

    func testDefaultManualOverridePauseDuration() {
        XCTAssertEqual(store.manualOverridePauseDuration, 300.0)
    }

    func testResetToDefaults() {
        store.lightThreshold = 99.0
        store.debounceDuration = 20.0
        store.enableAutoSwitch = false
        store.launchAtLogin = true
        store.manualOverridePauseDuration = 60.0

        store.resetToDefaults()

        XCTAssertEqual(store.lightThreshold, 400.0)
        XCTAssertEqual(store.debounceDuration, 5.0)
        XCTAssertEqual(store.enableAutoSwitch, true)
        XCTAssertEqual(store.launchAtLogin, false)
        XCTAssertEqual(store.manualOverridePauseDuration, 300.0)
    }

    func testPersistLightThreshold() {
        store.lightThreshold = 25.0
        let fresh = SettingsStore(defaults: testDefaults)
        XCTAssertEqual(fresh.lightThreshold, 25.0)
    }
}
