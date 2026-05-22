import Foundation
import Observation

@Observable
public final class ThresholdEngine {
    private let settings: SettingsStore
    private var debounceTimer: DebounceTimerProtocol?
    private var pendingMode: AppearanceMode?

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
        let darkThreshold = lightThreshold * 0.7

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
        isPaused = true
        debounceTimer?.cancel()
        pendingMode = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + settings.manualOverridePauseDuration) { [weak self] in
            self?.isPaused = false
        }
    }

    private func triggerSwitch(to mode: AppearanceMode) {
        guard mode != currentMode else { return }
        currentMode = mode
        lastSwitchTime = Date()
        pendingMode = nil
        delegate?.engineDidDetermineNewMode(mode)
    }
}
