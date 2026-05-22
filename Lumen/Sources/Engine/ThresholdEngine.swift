import Foundation
import Observation

@Observable
public final class ThresholdEngine {
    /// Hysteresis ratio: dark threshold = lightThreshold * this value.
    /// Set below 1.0 to create a dead band that prevents rapid toggling near the threshold.
    private static let hysteresisRatio = 0.7

    private let settings: SettingsStore
    private var debounceTimer: DebounceTimerProtocol?
    private var pendingMode: AppearanceMode?
    private var manualOverrideWorkItem: DispatchWorkItem?

    public weak var delegate: ThresholdEngineDelegate?
    public var currentMode: AppearanceMode = .dark
    public var lastSwitchTime: Date?
    public var isPaused: Bool = false

    public init(settings: SettingsStore) {
        self.settings = settings
    }

    public func process(_ reading: ALSReading) {
        guard reading.lux >= 0 else { return }
        guard settings.enableAutoSwitch else { return }
        guard !isPaused else { return }

        let lightThreshold = settings.lightThreshold
        let darkThreshold = lightThreshold * Self.hysteresisRatio

        let threshold = currentMode == .light ? darkThreshold : lightThreshold
        let shouldSwitchToLight = reading.lux >= threshold
        let targetMode: AppearanceMode = shouldSwitchToLight ? .light : .dark

        if targetMode != currentMode {
            if pendingMode != targetMode {
                pendingMode = targetMode
                debounceTimer = DebounceTimer(duration: settings.debounceDuration) { [weak self] in
                    self?.triggerSwitch(to: targetMode)
                }
                debounceTimer?.start()
            }
        } else {
            if pendingMode != nil {
                debounceTimer?.cancel()
                pendingMode = nil
            }
        }
    }

    public func reset() {
        debounceTimer?.cancel()
        pendingMode = nil
    }

    public func pauseForManualOverride() {
        manualOverrideWorkItem?.cancel()
        isPaused = true
        debounceTimer?.cancel()
        pendingMode = nil
        let item = DispatchWorkItem { [weak self] in
            self?.isPaused = false
        }
        manualOverrideWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + settings.manualOverridePauseDuration, execute: item)
    }

    private func triggerSwitch(to mode: AppearanceMode) {
        guard mode != currentMode else { return }
        currentMode = mode
        lastSwitchTime = Date()
        pendingMode = nil
        delegate?.engineDidDetermineNewMode(mode)
    }
}
