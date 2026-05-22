import Foundation

public enum LuxLevel: Double, CaseIterable, Identifiable {
    case darkRoom = 10
    case dimIndoor = 100
    case brightIndoor = 400
    case overcast = 6400
    case sunny = 12800
    case directSun = 25600

    public var id: Double { rawValue }

    public var displayValue: String {
        if rawValue >= 1000 {
            return String(format: "%.1fk", rawValue / 1000)
        }
        return String(format: "%.0f", rawValue)
    }
}

enum SettingsDefaults {
    static let lightThreshold = LuxLevel.brightIndoor.rawValue
    static let debounceDuration = 5.0
    static let enableAutoSwitch = true
    static let manualOverridePauseDuration = 300.0
    static let launchAtLogin = false
}
