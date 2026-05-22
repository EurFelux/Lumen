import XCTest
@testable import Lumen

final class SettingsDefaultsTests: XCTestCase {
    func testDefaultValues() {
        XCTAssertEqual(SettingsDefaults.lightThreshold, 400.0)
        XCTAssertEqual(SettingsDefaults.debounceDuration, 5.0)
        XCTAssertEqual(SettingsDefaults.enableAutoSwitch, true)
        XCTAssertEqual(SettingsDefaults.manualOverridePauseDuration, 300.0)
        XCTAssertEqual(SettingsDefaults.launchAtLogin, false)
    }

    func testLightThresholdMatchesBrightIndoor() {
        XCTAssertEqual(SettingsDefaults.lightThreshold, LuxLevel.brightIndoor.rawValue)
    }
}
