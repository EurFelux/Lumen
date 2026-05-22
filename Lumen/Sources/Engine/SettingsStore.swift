import Foundation
import Combine

public final class SettingsStore: ObservableObject {

    private enum Keys {
        static let lightThreshold = "lumen-lightThreshold"
        static let debounceDuration = "lumen-debounceDuration"
        static let enableAutoSwitch = "lumen-enableAutoSwitch"
        static let launchAtLogin = "lumen-launchAtLogin"
        static let manualOverridePauseDuration = "lumen-manualOverridePauseDuration"
    }

    @Published public var lightThreshold: Double {
        didSet { defaults.set(lightThreshold, forKey: Keys.lightThreshold) }
    }

    @Published public var debounceDuration: Double {
        didSet { defaults.set(debounceDuration, forKey: Keys.debounceDuration) }
    }

    @Published public var enableAutoSwitch: Bool {
        didSet { defaults.set(enableAutoSwitch, forKey: Keys.enableAutoSwitch) }
    }

    @Published public var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }

    @Published public var manualOverridePauseDuration: Double {
        didSet { defaults.set(manualOverridePauseDuration, forKey: Keys.manualOverridePauseDuration) }
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.lightThreshold = defaults.double(forKey: Keys.lightThreshold).nonZeroOrDefault(SettingsDefaults.lightThreshold)
        self.debounceDuration = defaults.double(forKey: Keys.debounceDuration).nonZeroOrDefault(SettingsDefaults.debounceDuration)
        self.enableAutoSwitch = defaults.object(forKey: Keys.enableAutoSwitch) as? Bool ?? SettingsDefaults.enableAutoSwitch
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        self.manualOverridePauseDuration = defaults.double(forKey: Keys.manualOverridePauseDuration).nonZeroOrDefault(SettingsDefaults.manualOverridePauseDuration)
    }

    public func resetToDefaults() {
        lightThreshold = SettingsDefaults.lightThreshold
        debounceDuration = SettingsDefaults.debounceDuration
        enableAutoSwitch = SettingsDefaults.enableAutoSwitch
        launchAtLogin = SettingsDefaults.launchAtLogin
        manualOverridePauseDuration = SettingsDefaults.manualOverridePauseDuration
    }
}

private extension Double {
    func nonZeroOrDefault(_ defaultVal: Double) -> Double {
        self == 0 ? defaultVal : self
    }
}
