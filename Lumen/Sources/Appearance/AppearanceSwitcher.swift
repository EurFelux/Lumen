import Foundation
import AppKit

public final class AppearanceSwitcher: AppearanceSwitching {
    private var appleScriptRunner: AppleScriptRunnerProtocol
    public private(set) var workingMethod: AppearanceSwitchingMethod?

    public enum AppearanceSwitchingMethod {
        case skylightNotifying
        case skylightLegacy
        case appleScript
    }

    public init(appleScriptRunner: AppleScriptRunnerProtocol? = nil) {
        self.appleScriptRunner = appleScriptRunner ?? AppleScriptRunner()
    }

    @discardableResult
    public func setAppearance(_ mode: AppearanceMode) -> Bool {
        let rawValue = Int32(mode.rawValue)

        // Method 1: SkyLight notifying (preferred — broadcasts to running apps)
        let notifyingFn = PrivateAPILoader.SLSSetAppearanceThemeNotifyingPtr()
        if notifyingFn(rawValue, true) {
            workingMethod = .skylightNotifying
            return true
        }

        // Method 2: SkyLight legacy (silent switch)
        let legacyFn = PrivateAPILoader.SLSSetAppearanceThemeLegacyPtr()
        legacyFn(rawValue)

        // Verify the switch actually took effect
        if currentAppearance() == mode {
            workingMethod = .skylightLegacy
            return true
        }

        // Method 3: AppleScript fallback (slow but universal)
        if setAppearanceViaAppleScript(mode) {
            workingMethod = .appleScript
            return true
        }

        return false
    }

    public func currentAppearance() -> AppearanceMode {
        let fn = PrivateAPILoader.SLSGetAppearanceThemeLegacyPtr()
        let raw = fn()
        return AppearanceMode(rawValue: Int(raw)) ?? .dark
    }

    private func setAppearanceViaAppleScript(_ mode: AppearanceMode) -> Bool {
        let darkModeFlag = mode == .dark ? "true" : "false"
        let script = """
        tell application "System Events"
            tell appearance preferences
                set dark mode to \(darkModeFlag)
            end tell
        end tell
        """
        return appleScriptRunner.run(script: script)
    }
}
