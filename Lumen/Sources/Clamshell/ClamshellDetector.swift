import Foundation
import IOKit

/// Clamshell (lid) state detector using IOKit push notifications.
/// Uses IOServiceAddInterestNotification for real-time lid state changes (NOT polling).
public final class ClamshellDetector: NSObject, ClamshellDetecting {
    private var notificationPort: IONotificationPortRef?
    private var addedNotification: io_object_t = 0
    private var state: ClamshellState = .open
    
    private var onStateChange: ((ClamshellState) -> Void)?
    
    public override init() {
        super.init()
        state = readInitialState()
        registerForClamshellNotifications()
    }
    
    deinit {
        cleanup()
    }
    
    /// Returns current clamshell state (cached, updated via push notifications).
    public func currentState() -> ClamshellState {
        return state
    }
    
    /// Registers for IOKit push notifications on AppleClamshellState changes.
    /// Uses IOServiceAddInterestNotification (NOT ioreg shell process).
    private func registerForClamshellNotifications() {
        guard let service = IOKitBridging.openService(named: "AppleClamshellState") else {
            return
        }
        defer { IOKitBridging.closeService(service) }
        
        let port = IONotificationPortCreate(kIOMainPortDefault)
        notificationPort = port
        
        guard let port = port else {
            return
        }
        
        let runLoopSource = IONotificationPortGetRunLoopSource(port).takeUnretainedValue()
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .defaultMode)
        
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        
        let result = IOServiceAddInterestNotification(
            port,
            service,
            kIOGeneralInterest,
            { (refcon, service, messageType, messageArgument) in
                guard let refcon = refcon else { return }
                let detector = Unmanaged<ClamshellDetector>.fromOpaque(refcon).takeUnretainedValue()
                detector.handleClamshellNotification()
            },
            selfPtr,
            &addedNotification
        )
        
        if result != KERN_SUCCESS {
            cleanup()
        }
    }
    
    /// Reads initial clamshell state from IORegistry (called once on init).
    private func readInitialState() -> ClamshellState {
        guard let service = IOKitBridging.openService(named: "AppleClamshellState") else {
            return .open
        }
        defer { IOKitBridging.closeService(service) }
        
        let stateValue: Bool? = IOKitBridging.readProperty(service, "AppleClamshellState")
        guard let value = stateValue else {
            return .open
        }
        
        return value ? .closed : .open
    }
    
    /// Called when IOKit notifies of clamshell state change.
    private func handleClamshellNotification() {
        let newState = readInitialState()
        if newState != state {
            state = newState
            onStateChange?(newState)
        }
    }
    
    /// Cleanup IOKit resources.
    private func cleanup() {
        if addedNotification != 0 {
            IOObjectRelease(addedNotification)
            addedNotification = 0
        }
        if let port = notificationPort {
            IONotificationPortDestroy(port)
            notificationPort = nil
        }
    }
    
    /// Sets a callback for state changes (used by MainAppController).
    public func setOnStateChange(_ handler: @escaping (ClamshellState) -> Void) {
        onStateChange = handler
    }
}
