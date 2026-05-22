import Foundation

// MARK: - ALS Reading Protocol
/// Protocol for components that can read ambient light sensor data
public protocol ALSReadingProtocol: AnyObject {
    /// Returns the current ALS reading, or nil if unavailable
    func currentReading() -> ALSReading?
}

// MARK: - Appearance Switching Protocol
/// Protocol for components that can switch system appearance
public protocol AppearanceSwitching: AnyObject {
    /// Sets the system appearance to the specified mode
    /// - Returns: true if successful, false if all methods failed
    @discardableResult
    func setAppearance(_ mode: AppearanceMode) -> Bool

    /// Returns the current system appearance
    func currentAppearance() -> AppearanceMode
}

// MARK: - Clamshell Detection Protocol
/// Protocol for components that detect clamshell (lid) state
public protocol ClamshellDetecting: AnyObject {
    /// Returns the current clamshell state
    func currentState() -> ClamshellState

    /// Sets a callback for state changes
    func setOnStateChange(_ handler: @escaping (ClamshellState) -> Void)
}

// MARK: - Threshold Engine Delegate
/// Delegate protocol for receiving appearance change decisions from the threshold engine
public protocol ThresholdEngineDelegate: AnyObject {
    /// Called when the threshold engine determines the mode should change
    func engineDidDetermineNewMode(_ mode: AppearanceMode)
}
