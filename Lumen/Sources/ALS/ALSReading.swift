import Foundation

/// Represents a single reading from the ambient light sensor
public struct ALSReading: Equatable {
    /// Lux value from the sensor (0 = pitch dark, 30000+ = direct sunlight)
    public let lux: Double

    /// Timestamp of the reading
    public let timestamp: Date

    /// Which ALS method produced this reading
    public let source: ALSSource

    public init(lux: Double, timestamp: Date = Date(), source: ALSSource) {
        self.lux = lux
        self.timestamp = timestamp
        self.source = source
    }
}

/// Source of an ALS reading (determines fallback cascade order)
public enum ALSSource: String, CaseIterable, Equatable {
    case hid = "HID"
    case ioRegistry = "IORegistry"
    case lmuController = "LMU"
    case displayServices = "DisplayServices"
}
