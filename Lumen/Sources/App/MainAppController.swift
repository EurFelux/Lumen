import Foundation
import AppKit
import Combine
import OSLog

public final class MainAppController: NSObject {
    private let alsReader: ALSReadingProtocol
    private let thresholdEngine: ThresholdEngine
    private let appearanceSwitcher: AppearanceSwitching
    private let clamshellDetector: ClamshellDetecting
    private let menuBarController: MenuBarController
    private let settings: SettingsStore
    private let launchAtLoginManager: LaunchAtLoginManager
    private let logger = Logger(subsystem: "com.lumen.app", category: "MainAppController")

    private var pollingTimer: Timer?
    private var notificationObserver: NSObjectProtocol?
    private var cancellables = Set<AnyCancellable>()

    var lastSelfTriggeredSwitchTime: Date?
    var isPollingPaused: Bool = false

    public init(
        alsReader: ALSReadingProtocol,
        thresholdEngine: ThresholdEngine,
        appearanceSwitcher: AppearanceSwitching,
        clamshellDetector: ClamshellDetecting,
        menuBarController: MenuBarController,
        settings: SettingsStore,
        launchAtLoginManager: LaunchAtLoginManager
    ) {
        self.alsReader = alsReader
        self.thresholdEngine = thresholdEngine
        self.appearanceSwitcher = appearanceSwitcher
        self.clamshellDetector = clamshellDetector
        self.menuBarController = menuBarController
        self.settings = settings
        self.launchAtLoginManager = launchAtLoginManager
        super.init()
    }

    public func start() {
        setupWiring()
        detectAndDisableMacOSAutoMode()
        bindClamshellDetector()
        bindLaunchAtLogin()
        observeSettings()
        observeAppearanceChanges()
        startPolling()
        updateInitialUI()
    }

    public func stop() {
        stopPolling()
        removeNotificationObserver()
    }

    private func setupWiring() {
        thresholdEngine.delegate = self
        menuBarController.delegate = self
    }

    private func detectAndDisableMacOSAutoMode() {
        let key = "AppleInterfaceStyleSwitchesAutomatically"
        guard UserDefaults.standard.bool(forKey: key) else { return }

        UserDefaults.standard.set(false, forKey: key)
        logger.info("Disabled macOS Auto Mode switching")
        menuBarController.showAutoModeDisabledNotice()
    }

    private func startPolling() {
        let timer = Timer(timeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.performPollingCycle()
        }
        RunLoop.main.add(timer, forMode: .common)
        pollingTimer = timer
    }

    func performPollingCycle() {
        guard !isPollingPaused else { return }
        guard settings.enableAutoSwitch else { return }

        if let reading = alsReader.currentReading() {
            menuBarController.updateCurrentReading(reading)
            thresholdEngine.process(reading)
        }
    }

    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    private func bindClamshellDetector() {
        clamshellDetector.setOnStateChange { [weak self] state in
            DispatchQueue.main.async {
                self?.handleClamshellStateChange(state)
            }
        }
    }

    func handleClamshellStateChange(_ state: ClamshellState) {
        switch state {
        case .closed:
            isPollingPaused = true
            logger.debug("Clamshell closed — pausing ALS polling")
        case .open:
            isPollingPaused = false
            logger.debug("Clamshell open — resuming ALS polling")
        }
    }

    private func bindLaunchAtLogin() {
        launchAtLoginManager.bind(to: settings)
    }

    private func observeSettings() {
        settings.$enableAutoSwitch
            .sink { [weak self] _ in
                self?.handleAutoSwitchChange()
            }
            .store(in: &cancellables)
    }

    private func handleAutoSwitchChange() {
        thresholdEngine.reset()
    }

    private func observeAppearanceChanges() {
        notificationObserver = DistributedNotificationCenter.default.addObserver(
            forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleAppearanceChangeNotification()
        }
    }

    func handleAppearanceChangeNotification() {
        if let lastTime = lastSelfTriggeredSwitchTime,
           Date().timeIntervalSince(lastTime) < 1.0 {
            return
        }

        logger.info("Manual override detected — pausing auto-switching")
        thresholdEngine.pauseForManualOverride()

        let mode = appearanceSwitcher.currentAppearance()
        menuBarController.updateIcon(for: mode)
    }

    private func removeNotificationObserver() {
        if let observer = notificationObserver {
            DistributedNotificationCenter.default.removeObserver(observer)
            notificationObserver = nil
        }
    }

    private func updateInitialUI() {
        let mode = appearanceSwitcher.currentAppearance()
        thresholdEngine.currentMode = mode
        menuBarController.updateIcon(for: mode)
    }
}

extension MainAppController: ThresholdEngineDelegate {
    public func engineDidDetermineNewMode(_ mode: AppearanceMode) {
        lastSelfTriggeredSwitchTime = Date()
        appearanceSwitcher.setAppearance(mode)
        menuBarController.updateIcon(for: mode)
    }
}

extension MainAppController: MenuBarControllerDelegate {
    public func menuBarControllerDidRequestEnableAutoSwitch() {
        thresholdEngine.reset()
    }

    public func menuBarControllerDidRequestQuit() {
        NSApp.terminate(nil)
    }

    public func currentAppearanceMode() -> AppearanceMode {
        appearanceSwitcher.currentAppearance()
    }
}
