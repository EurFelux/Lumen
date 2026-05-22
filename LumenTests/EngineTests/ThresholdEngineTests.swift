import XCTest
@testable import Lumen

final class MockThresholdEngineDelegate: ThresholdEngineDelegate {
    var lastMode: AppearanceMode?
    var expectation: XCTestExpectation?
    var expectedMode: AppearanceMode?

    func engineDidDetermineNewMode(_ mode: AppearanceMode) {
        lastMode = mode
        if let expectedMode = expectedMode, mode == expectedMode {
            expectation?.fulfill()
        } else if expectedMode == nil {
            expectation?.fulfill()
        }
    }
}

final class ThresholdEngineTests: XCTestCase {
    var engine: ThresholdEngine!
    var settings: SettingsStore!
    var delegate: MockThresholdEngineDelegate!

    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "test.threshold.\(UUID().uuidString)")!
        settings = SettingsStore(defaults: testDefaults)
        settings.resetToDefaults()
        delegate = MockThresholdEngineDelegate()
        engine = ThresholdEngine(settings: settings)
        engine.delegate = delegate
        engine.reset()
    }

    func testTriggersLightModeWhenAboveThreshold() {
        settings.lightThreshold = 10.0
        settings.debounceDuration = 0.1
        settings.enableAutoSwitch = true

        engine.currentMode = .dark
        engine.process(ALSReading(lux: 15.0, source: .hid))

        XCTAssertNil(delegate.lastMode)

        let expectation = self.expectation(description: "Switch to light mode")
        delegate.expectation = expectation
        delegate.expectedMode = .light

        wait(for: [expectation], timeout: 0.15)
        XCTAssertEqual(delegate.lastMode, .light)
    }

    func testTriggersDarkModeWhenBelowThreshold() {
        settings.lightThreshold = 10.0
        settings.debounceDuration = 0.1
        settings.enableAutoSwitch = true

        engine.currentMode = .light
        engine.process(ALSReading(lux: 3.0, source: .hid))

        XCTAssertNil(delegate.lastMode)

        let expectation = self.expectation(description: "Switch to dark mode")
        delegate.expectation = expectation
        delegate.expectedMode = .dark

        wait(for: [expectation], timeout: 0.15)
        XCTAssertEqual(delegate.lastMode, .dark)
    }

    func testHysteresisBandMaintainsMode() {
        settings.lightThreshold = 10.0
        settings.debounceDuration = 0.1
        settings.enableAutoSwitch = true

        engine.currentMode = .light
        engine.process(ALSReading(lux: 7.0, source: .hid))

        let expectation = self.expectation(description: "Should not switch")
        expectation.isInverted = true
        delegate.expectation = expectation

        wait(for: [expectation], timeout: 0.15)
        XCTAssertNil(delegate.lastMode)
    }

    func testNegativeOneRejected() {
        engine.process(ALSReading(lux: -1.0, source: .hid))
        XCTAssertNil(delegate.lastMode)

        engine.process(ALSReading(lux: -100.0, source: .hid))
        XCTAssertNil(delegate.lastMode)
    }

    func testAutoSwitchDisabledIgnoresReadings() {
        settings.enableAutoSwitch = false
        engine.currentMode = .dark
        engine.process(ALSReading(lux: 50.0, source: .hid))
        XCTAssertNil(delegate.lastMode)
    }

    func testRapidFluctuationRequiresSustainedReading() {
        settings.lightThreshold = 10.0
        settings.debounceDuration = 0.2
        settings.enableAutoSwitch = true

        engine.currentMode = .dark

        engine.process(ALSReading(lux: 15.0, source: .hid))
        engine.process(ALSReading(lux: 3.0, source: .hid))
        engine.process(ALSReading(lux: 15.0, source: .hid))

        let expectation = self.expectation(description: "Should not switch after fluctuation")
        expectation.isInverted = true
        delegate.expectation = expectation

        wait(for: [expectation], timeout: 0.15)
        XCTAssertNil(delegate.lastMode)
    }
}
