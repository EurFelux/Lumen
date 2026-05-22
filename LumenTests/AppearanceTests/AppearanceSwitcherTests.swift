import XCTest
@testable import Lumen

final class MockAppleScriptRunner: AppleScriptRunnerProtocol {
    var shouldSucceed = true
    var lastScript: String?

    func run(script: String) -> Bool {
        lastScript = script
        return shouldSucceed
    }
}

final class AppearanceSwitcherTests: XCTestCase {
    var switcher: AppearanceSwitcher!
    var mockAppleScript: MockAppleScriptRunner!

    override func setUp() {
        super.setUp()
        mockAppleScript = MockAppleScriptRunner()
        switcher = AppearanceSwitcher(appleScriptRunner: mockAppleScript)
    }

    override func tearDown() {
        switcher = nil
        mockAppleScript = nil
        super.tearDown()
    }

    func testSetAppearanceReturnsTrue() {
        let result = switcher.setAppearance(.light)
        XCTAssertTrue(result)
    }

    func testSetAppearanceDarkReturnsTrue() {
        let result = switcher.setAppearance(.dark)
        XCTAssertTrue(result)
    }

    func testAppleScriptFallbackIsInjectable() {
        let script = "tell application \"System Events\" to return true"
        XCTAssertTrue(mockAppleScript.run(script: script))

        mockAppleScript.shouldSucceed = false
        XCTAssertFalse(mockAppleScript.run(script: script))
    }

    func testCurrentAppearanceReturnsValidMode() {
        let mode = switcher.currentAppearance()
        XCTAssertTrue(mode == .light || mode == .dark)
    }

    func testWorkingMethodSetAfterSuccessfulSwitch() {
        _ = switcher.setAppearance(.light)
        XCTAssertNotNil(switcher.workingMethod)
    }
}
