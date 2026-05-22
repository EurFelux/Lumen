import Foundation

/// macOS system appearance mode
/// Note: rawValue matches SLSGetAppearanceThemeLegacy return values (0=Light, 1=Dark)
public enum AppearanceMode: Int, CaseIterable, Equatable {
    case light = 0
    case dark = 1

    /// Opposite mode toggle
    public var toggled: AppearanceMode {
        self == .light ? .dark : .light
    }

    /// Human-readable name
    public var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    /// SF Symbol name for menu bar icon
    public var symbolName: String {
        switch self {
        case .light: return "sun.max"
        case .dark: return "moon.stars"
        }
    }
}
