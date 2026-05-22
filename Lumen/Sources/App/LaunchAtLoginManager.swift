import Foundation
import Combine
import OSLog
import ServiceManagement

// MARK: - Abstraction for testability

public protocol SMAppServiceProtocol {
    var status: SMAppService.Status { get }
    func register() throws
    func unregister() throws
}

extension SMAppService: SMAppServiceProtocol {}

// MARK: - Manager

public final class LaunchAtLoginManager {
    private let service: SMAppServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: "com.lumen.app", category: "LaunchAtLogin")

    public init(service: SMAppServiceProtocol = SMAppService.mainApp) {
        self.service = service
    }

    public var isEnabled: Bool {
        service.status == .enabled
    }

    public func enable() throws {
        try service.register()
    }

    public func disable() throws {
        try service.unregister()
    }

    /// Binds `SettingsStore.launchAtLogin` to SMAppService registration via Combine.
    public func bind(to settings: SettingsStore) {
        // Initial sync
        syncIfNeeded(shouldBeEnabled: settings.launchAtLogin)

        // Observe changes via Combine
        settings.$launchAtLogin
            .sink { [weak self] enabled in
                self?.syncIfNeeded(shouldBeEnabled: enabled)
            }
            .store(in: &cancellables)
    }

    // MARK: - Private

    private func syncIfNeeded(shouldBeEnabled: Bool) {
        guard shouldBeEnabled != isEnabled else { return }
        do {
            if shouldBeEnabled {
                try enable()
                logger.debug("Launch-at-login registered")
            } else {
                try disable()
                logger.debug("Launch-at-login unregistered")
            }
        } catch {
            logger.error("Failed to update launch-at-login: \(error.localizedDescription)")
        }
    }
}
