import Foundation

// MARK: - Private Framework Paths
private let BEZEL_SERVICES_PATH = "/System/Library/PrivateFrameworks/BezelServices.framework/BezelServices"
private let SKYLIGHT_PATH = "/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight"
private let DISPLAY_SERVICES_PATH = "/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices"

// MARK: - ALS Types (from IOKit/hidsystem/IOHIDServiceClient.h)
public typealias IOHIDServiceClientRef = UnsafeMutableRawPointer
public typealias IOHIDEventRef = UnsafeMutableRawPointer
public let kAmbientLightSensorEvent: Int32 = 12
public func IOHIDEventFieldBase(_ type: Int32) -> Int32 { return type << 16 }


// MARK: - Framework Loader
public enum PrivateAPILoader {
    private static let _bezelHandle: UnsafeMutableRawPointer? = dlopen(BEZEL_SERVICES_PATH, RTLD_LAZY)
    private static let _skylightHandle: UnsafeMutableRawPointer? = dlopen(SKYLIGHT_PATH, RTLD_LAZY)
    private static let _displayHandle: UnsafeMutableRawPointer? = dlopen(DISPLAY_SERVICES_PATH, RTLD_LAZY)
    
    public static func loadBezelServices() -> UnsafeMutableRawPointer? {
        return _bezelHandle
    }
    
    public static func loadSkyLight() -> UnsafeMutableRawPointer? {
        return _skylightHandle
    }
    
    public static func loadDisplayServices() -> UnsafeMutableRawPointer? {
        return _displayHandle
    }
    
    // MARK: - Specific API accessors (typed function pointers)
    
    /// ALCALSCopyALSServiceClient — returns lux directly from HID sensor
    public static func ALCALSCopyALSServiceClientPtr() -> @convention(c) () -> IOHIDServiceClientRef? {
        guard let handle = loadBezelServices() else { return { return nil } }
        guard let sym = dlsym(handle, "ALCALSCopyALSServiceClient") else { return { return nil } }
        return unsafeBitCast(sym, to: (@convention(c) () -> IOHIDServiceClientRef?).self)
    }
    
    /// IOHIDServiceClientCopyEvent — copy an HID event from a service client
    public static func IOHIDServiceClientCopyEventPtr() -> @convention(c) (IOHIDServiceClientRef, Int64, Int32, Int64) -> IOHIDEventRef? {
        guard let handle = loadBezelServices() else { return { _, _, _, _ in return nil } }
        guard let sym = dlsym(handle, "IOHIDServiceClientCopyEvent") else { return { _, _, _, _ in return nil } }
        return unsafeBitCast(sym, to: (@convention(c) (IOHIDServiceClientRef, Int64, Int32, Int64) -> IOHIDEventRef?).self)
    }
    
    /// IOHIDEventGetFloatValue — get float value from an HID event
    public static func IOHIDEventGetFloatValuePtr() -> @convention(c) (IOHIDEventRef, Int32) -> Double {
        guard let handle = loadBezelServices() else { return { _, _ in return 0.0 } }
        guard let sym = dlsym(handle, "IOHIDEventGetFloatValue") else { return { _, _ in return 0.0 } }
        return unsafeBitCast(sym, to: (@convention(c) (IOHIDEventRef, Int32) -> Double).self)
    }
    
    /// SLSGetAppearanceThemeLegacy — get current appearance (0=light, 1=dark)
    public static func SLSGetAppearanceThemeLegacyPtr() -> @convention(c) () -> Int32 {
        guard let handle = loadSkyLight() else { return { return 0 } }
        guard let sym = dlsym(handle, "SLSGetAppearanceThemeLegacy") else { return { return 0 } }
        return unsafeBitCast(sym, to: (@convention(c) () -> Int32).self)
    }
    
    /// SLSSetAppearanceThemeNotifying — set appearance with notification to apps
    public static func SLSSetAppearanceThemeNotifyingPtr() -> @convention(c) (Int32, Bool) -> Bool {
        guard let handle = loadSkyLight() else { return { _, _ in false } }
        guard let sym = dlsym(handle, "SLSSetAppearanceThemeNotifying") else { return { _, _ in false } }
        return unsafeBitCast(sym, to: (@convention(c) (Int32, Bool) -> Bool).self)
    }
    
    /// SLSSetAppearanceThemeLegacy — legacy set appearance
    public static func SLSSetAppearanceThemeLegacyPtr() -> @convention(c) (Int32) -> Void {
        guard let handle = loadSkyLight() else { return { _ in } }
        guard let sym = dlsym(handle, "SLSSetAppearanceThemeLegacy") else { return { _ in } }
        return unsafeBitCast(sym, to: (@convention(c) (Int32) -> Void).self)
    }
    
    /// DisplayServicesClient.aggregateLux via NSClassFromString + performSelector
    public static func displayServicesAggregatedLux() -> Double? {
        guard loadDisplayServices() != nil else { return nil }
        guard let cls = NSClassFromString("DisplayServicesClient") else { return nil }
        let obj = (cls as? NSObject.Type)?.perform(Selector(("new")))?.takeRetainedValue()
        let lux = (obj as? NSObject)?.perform(Selector(("copyPropertyForKey:")), with: "AggregatedLux")?.takeRetainedValue() as? NSNumber
        return lux?.doubleValue
    }
}
