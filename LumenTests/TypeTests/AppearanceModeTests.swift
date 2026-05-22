import XCTest
@testable import Lumen

final class AppearanceModeTests: XCTestCase {
    func testAppearanceModeRawValues() {
        XCTAssertEqual(AppearanceMode.light.rawValue, 0)
        XCTAssertEqual(AppearanceMode.dark.rawValue, 1)
    }

    func testAppearanceModeToggle() {
        XCTAssertEqual(AppearanceMode.light.toggled, .dark)
        XCTAssertEqual(AppearanceMode.dark.toggled, .light)
    }

    func testAppearanceModeCaseCount() {
        XCTAssertEqual(AppearanceMode.allCases.count, 2)
    }

    func testAppearanceModeDisplayName() {
        XCTAssertEqual(AppearanceMode.light.displayName, "Light")
        XCTAssertEqual(AppearanceMode.dark.displayName, "Dark")
    }

    func testAppearanceModeSymbolName() {
        XCTAssertEqual(AppearanceMode.light.symbolName, "sun.max")
        XCTAssertEqual(AppearanceMode.dark.symbolName, "moon.stars")
    }
}
