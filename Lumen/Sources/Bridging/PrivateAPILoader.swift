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

// MARK: - Private API Declarations (dlsym targets)
// BezelServices
@_silgen_name("ALCALSCopyALSServiceClient")
public func ALCALSCopyALSServiceClient() -> IOHIDServiceClientRef

@_silgen_name("IOHIDServiceClientCopyEvent")
public func IOHIDServiceClientCopyEvent(_ service: IOHIDServiceClientRef, _ type: Int64, _ eventType: Int32, _ options: Int64) -> IOHIDEventRef

@_silgen_name("IOHIDEventGetFloatValue")
public func IOHIDEventGetFloatValue(_ event: IOHIDEventRef, _ field: Int32) -> Double

// SkyLight
@_silgen_name("SLSGetAppearanceThemeLegacy")
public func SLSGetAppearanceThemeLegacy() -> Int32

@_silgen_name("SLSSetAppearanceThemeLegacy")
public func SLSSetAppearanceThemeLegacy(_ mode: Int32)

@_silgen_name("SLSSetAppearanceThemeNotifying")
public func SLSSetAppearanceThemeNotifying(_ mode: Int32, _ notify: Bool) -> Bool

// MARK: - Framework Loader
public enum PrivateAPILoader {
    private static var _bezelHandle: UnsafeMutableRawPointer?
    private static var _skylightHandle: UnsafeMutableRawPointer?
    private static var _displayHandle: UnsafeMutableRawPointer?
    
    // BezelServices ALS
    public static func loadBezelServices() -> UnsafeMutableRawPointer? {
        if let existing = _bezelHandle { return existing }
        let handle = dlopen(BEZEL_SERVICES_PATH, RTLD_LAZY)
        _bezelHandle = handle
        return handle
    }
    
    // SkyLight appearance switching
    public static func loadSkyLight() -> UnsafeMutableRawPointer? {
        if let existing = _skylightHandle { return existing }
        let handle = dlopen(SKYLIGHT_PATH, RTLD_LAZY)
        _skylightHandle = handle
        return handle
    }
    
    // DisplayServices
    public static func loadDisplayServices() -> UnsafeMutableRawPointer? {
        if let existing = _displayHandle { return existing }
        let handle = dlopen(DISPLAY_SERVICES_PATH, RTLD_LAZY)
        _displayHandle = handle
        return handle
    }
    
    // Resolve symbol with dlsym from loaded handle
    public static func resolveSymbol<T>(_ handle: UnsafeMutableRawPointer?, _ symbol: String) -> T? {
        guard let handle = handle else { return nil }
        guard let ptr = dlsym(handle, symbol) else { return nil }
        return unsafeBitCast(ptr, to: T.self)
    }
    
    // MARK: - Specific API accessors (typed function pointers)
    
    /// ALCALSCopyALSServiceClient — returns lux directly from HID sensor
    public static func ALCALSCopyALSServiceClientPtr() -> @convention(c) () -> IOHIDServiceClientRef? {
        guard let handle = loadBezelServices() else { return { return nil } }
        guard let sym = dlsym(handle, "ALCALSCopyALSServiceClient") else { return { return nil } }
        return unsafeBitCast(sym, to: (@convention(c) () -> IOHIDServiceClientRef?).self)
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
        let obj = (cls as? NSObject.Type)?.perform(Selector(("new")))?.takeUnretainedValue()
        let lux = (obj as? NSObject)?.perform(Selector(("copyPropertyForKey:")), with: "AggregatedLux")?.takeUnretainedValue() as? NSNumber
        return lux?.doubleValue
    }
}
