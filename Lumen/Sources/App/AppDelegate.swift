import AppKit

public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var mainController: MainAppController!

    public func applicationDidFinishLaunching(_ notification: Notification) {
        let settings = SettingsStore()
        let alsReader = ALSReader()
        let appearanceSwitcher = AppearanceSwitcher()
        let thresholdEngine = ThresholdEngine(settings: settings)
        let clamshellDetector = ClamshellDetector()
        let menuBarController = MenuBarController(settings: settings)
        let launchAtLoginManager = LaunchAtLoginManager()

        mainController = MainAppController(
            alsReader: alsReader,
            thresholdEngine: thresholdEngine,
            appearanceSwitcher: appearanceSwitcher,
            clamshellDetector: clamshellDetector,
            menuBarController: menuBarController,
            settings: settings,
            launchAtLoginManager: launchAtLoginManager
        )

        mainController.start()
    }

    public func applicationWillTerminate(_ notification: Notification) {
        mainController?.stop()
    }
}
