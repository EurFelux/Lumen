import XCTest
@testable import Lumen

final class MockALSReader: ALSReadingProtocol {
    var nextReading: ALSReading?

    func currentReading() -> ALSReading? {
        nextReading
    }
}

final class MockAppearanceSwitcher: AppearanceSwitching {
    var currentMode: AppearanceMode = .dark
    var setAppearanceCallCount = 0
    var lastSetMode: AppearanceMode?

    func setAppearance(_ mode: AppearanceMode) -> Bool {
        setAppearanceCallCount += 1
        lastSetMode = mode
        currentMode = mode
        return true
    }

    func currentAppearance() -> AppearanceMode {
        currentMode
    }
}

final class MockClamshellDetector: ClamshellDetecting {
    var state: ClamshellState = .open
    private var handler: ((ClamshellState) -> Void)?

    func currentState() -> ClamshellState {
        state
    }

    func setOnStateChange(_ handler: @escaping (ClamshellState) -> Void) {
        self.handler = handler
    }

    func simulateStateChange(_ state: ClamshellState) {
        self.state = state
        handler?(state)
    }
}

final class PollingTestDelegate: ThresholdEngineDelegate {
    var lastMode: AppearanceMode?

    func engineDidDetermineNewMode(_ mode: AppearanceMode) {
        lastMode = mode
    }
}

final class MainAppControllerTests: XCTestCase {
    private var controller: MainAppController!
    private var alsReader: MockALSReader!
    private var appearanceSwitcher: MockAppearanceSwitcher!
    private var thresholdEngine: ThresholdEngine!
    private var clamshellDetector: MockClamshellDetector!
    private var menuBarController: MenuBarController!
    private var settings: SettingsStore!
    private var launchAtLoginManager: LaunchAtLoginManager!

    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "test.main.\(UUID().uuidString)")!
        settings = SettingsStore(defaults: testDefaults)
        settings.resetToDefaults()

        alsReader = MockALSReader()
        appearanceSwitcher = MockAppearanceSwitcher()
        thresholdEngine = ThresholdEngine(settings: settings)
        clamshellDetector = MockClamshellDetector()
        menuBarController = MenuBarController(settings: settings)
        launchAtLoginManager = LaunchAtLoginManager()

        controller = MainAppController(
            alsReader: alsReader,
            thresholdEngine: thresholdEngine,
            appearanceSwitcher: appearanceSwitcher,
            clamshellDetector: clamshellDetector,
            menuBarController: menuBarController,
            settings: settings,
            launchAtLoginManager: launchAtLoginManager
        )
    }

    override func tearDown() {
        controller.stop()
        controller = nil
        super.tearDown()
    }

    func testWiresThresholdEngineDelegate() {
        controller.start()
        XCTAssertTrue(thresholdEngine.delegate === controller)
    }

    func testWiresMenuBarControllerDelegate() {
        controller.start()
        XCTAssertTrue(menuBarController.delegate === controller)
    }

    func testEngineDidDetermineNewModeSetsAppearance() {
        controller.start()
        thresholdEngine.delegate?.engineDidDetermineNewMode(.light)
        XCTAssertEqual(appearanceSwitcher.lastSetMode, .light)
        XCTAssertEqual(appearanceSwitcher.currentMode, .light)
    }

    func testEngineDidDetermineNewModeTracksSelfTriggeredTime() {
        controller.start()
        XCTAssertNil(controller.lastSelfTriggeredSwitchTime)
        thresholdEngine.delegate?.engineDidDetermineNewMode(.dark)
        XCTAssertNotNil(controller.lastSelfTriggeredSwitchTime)
    }

    func testDetectsAndDisablesMacOSAutoMode() {
        let key = "AppleInterfaceStyleSwitchesAutomatically"
        let originalValue = UserDefaults.standard.object(forKey: key)
        UserDefaults.standard.set(true, forKey: key)
        defer {
            if let originalValue = originalValue {
                UserDefaults.standard.set(originalValue, forKey: key)
            } else {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }

        controller.start()
        XCTAssertFalse(UserDefaults.standard.bool(forKey: key))
    }

    func testManualOverrideDetectedWhenNotSelfTriggered() {
        controller.start()
        controller.lastSelfTriggeredSwitchTime = nil
        controller.handleAppearanceChangeNotification()
        XCTAssertTrue(thresholdEngine.isPaused)
    }

    func testSelfTriggeredSwitchIgnoresNotification() {
        controller.start()
        controller.lastSelfTriggeredSwitchTime = Date()
        controller.handleAppearanceChangeNotification()
        XCTAssertFalse(thresholdEngine.isPaused)
    }

    func testClamshellClosedPausesPolling() {
        controller.start()
        controller.handleClamshellStateChange(.closed)
        XCTAssertTrue(controller.isPollingPaused)
    }

    func testClamshellOpenResumesPolling() {
        controller.start()
        controller.handleClamshellStateChange(.closed)
        controller.handleClamshellStateChange(.open)
        XCTAssertFalse(controller.isPollingPaused)
    }

    func testClamshellCallbackWiredThroughDetector() {
        controller.start()
        clamshellDetector.simulateStateChange(.closed)
        let expectation = self.expectation(description: "state change handled")
        DispatchQueue.main.async {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(controller.isPollingPaused)
    }

    func testCurrentAppearanceModeReturnsSwitcherValue() {
        controller.start()
        appearanceSwitcher.currentMode = .light
        XCTAssertEqual(controller.currentAppearanceMode(), .light)
    }

    func testDisableAutoSwitchStopsPolling() {
        controller.start()
        settings.enableAutoSwitch = false
        XCTAssertFalse(settings.enableAutoSwitch)
    }

    func testEnableAutoSwitchResetsEngine() {
        controller.start()
        thresholdEngine.currentMode = .dark
        thresholdEngine.process(ALSReading(lux: 100.0, source: .hid))
        controller.menuBarControllerDidRequestEnableAutoSwitch()
        XCTAssertFalse(thresholdEngine.isPaused)
    }

    func testPerformPollingCycleProcessesReading() {
        controller.start()
        settings.enableAutoSwitch = true
        alsReader.nextReading = ALSReading(lux: 100.0, source: .hid)
        thresholdEngine.currentMode = .dark

        controller.performPollingCycle()
        XCTAssertNotNil(alsReader.nextReading)
    }

    func testPerformPollingCycleSkippedWhenPaused() {
        controller.start()
        controller.isPollingPaused = true
        settings.enableAutoSwitch = true
        alsReader.nextReading = ALSReading(lux: 100.0, source: .hid)
        thresholdEngine.currentMode = .dark

        let mockDelegate = PollingTestDelegate()
        thresholdEngine.delegate = mockDelegate

        controller.performPollingCycle()

        XCTAssertNil(mockDelegate.lastMode)
    }

    func testStartDoesNotCrash() {
        controller.start()
        XCTAssertNotNil(controller)
    }

    func testStopDoesNotCrash() {
        controller.start()
        controller.stop()
    }

    func testStopTwiceDoesNotCrash() {
        controller.start()
        controller.stop()
        controller.stop()
    }
}
