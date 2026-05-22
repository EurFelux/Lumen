import Foundation
import IOKit

// MARK: - IOKit Bridging for ALS and Clamshell Detection

public enum IOKitBridging {
    /// Opens an IOKit service by name (e.g., "AppleLMUController", "AppleClamshellState")
    public static func openService(named name: String) -> io_service_t? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching(name))
        guard service != 0 else { return nil }
        return service
    }
    
    /// Closes an IOKit service handle
    public static func closeService(_ service: io_service_t) {
        IOObjectRelease(service)
    }
    
    /// Reads a CF/NS property from IOKit registry (e.g., "CurrentLux", "AppleClamshellState")
    public static func readProperty<T>(_ service: io_service_t, _ key: String) -> T? {
        guard let result = IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0) else {
            return nil
        }
        return result.takeRetainedValue() as? T
    }
    
    /// Creates an IOKit connection for AppleLMUController (method index 0 = read sensors)
    public static func createLMUConnection() -> io_connect_t? {
        var connect: io_connect_t = 0
        let service = openService(named: "AppleLMUController")
        guard let serv = service else { return nil }
        let result = IOServiceOpen(serv, mach_task_self_, 0, &connect)
        IOObjectRelease(serv)
        guard result == KERN_SUCCESS else { return nil }
        return connect
    }
    
    /// Closes an IOKit connection
    public static func closeConnection(_ connect: io_connect_t) {
        IOServiceClose(connect)
    }
}
