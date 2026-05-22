import Foundation
import IOKit

private enum LuxCalibrator {
    static func calibrate(_ raw: Double, source: ALSSource) -> Double {
        switch source {
        case .hid:
            return calibrateHID(raw)
        case .ioRegistry:
            return raw < 1.0 ? raw * 10000.0 : raw
        case .lmuController:
            return raw
        case .displayServices:
            return raw * 7.0
        }
    }

    private static func calibrateHID(_ raw: Double) -> Double {
        if raw < 10 {
            return raw * 5.0
        } else if raw < 50 {
            return 50.0 + (raw - 10.0) * 10.0
        } else if raw < 500 {
            return 450.0 + (raw - 50.0) * 25.0
        } else {
            return 11750.0 + (raw - 500.0) * 2.5
        }
    }
}

public final class ALSReader: NSObject, ALSReadingProtocol {
    private var cachedMethod: ALSSource?

    public func currentReading() -> ALSReading? {
        if let cached = cachedMethod, let reading = tryReading(from: cached) {
            return reading
        }

        for source in ALSSource.allCases {
            if let reading = tryReading(from: source) {
                cachedMethod = source
                return reading
            }
        }

        return nil
    }

    private func tryReading(from source: ALSSource) -> ALSReading? {
        switch source {
        case .hid:
            return readHID()
        case .ioRegistry:
            return readIORegistry()
        case .lmuController:
            return readLMU()
        case .displayServices:
            return readDisplayServices()
        }
    }

    private func readHID() -> ALSReading? {
        guard let clientPtr = PrivateAPILoader.ALCALSCopyALSServiceClientPtr() as? @convention(c) () -> IOHIDServiceClientRef?,
              let client = clientPtr() else { return nil }

        let event = IOHIDServiceClientCopyEvent(client, Int64(kAmbientLightSensorEvent), 0, 0)
        guard event != nil else {
            return nil
        }

        let raw = IOHIDEventGetFloatValue(event, IOHIDEventFieldBase(kAmbientLightSensorEvent))
        let lux = LuxCalibrator.calibrate(Double(raw), source: .hid)
        return ALSReading(lux: lux, source: .hid)
    }

    private func readIORegistry() -> ALSReading? {
        guard let service = IOKitBridging.openService(named: "AppleBacklightDisplay") else {
            return nil
        }
        defer { IOKitBridging.closeService(service) }

        if let raw = IOKitBridging.readPropertyDouble(service, "CurrentLux") {
            let lux = LuxCalibrator.calibrate(raw, source: .ioRegistry)
            return ALSReading(lux: lux, source: .ioRegistry)
        }

        if let raw = IOKitBridging.readPropertyDouble(service, "AmbientBrightness") {
            let lux = LuxCalibrator.calibrate(raw, source: .ioRegistry)
            return ALSReading(lux: lux, source: .ioRegistry)
        }

        return nil
    }

    private func readLMU() -> ALSReading? {
        guard let connection = IOKitBridging.createLMUConnection() else {
            return nil
        }
        defer { IOKitBridging.closeConnection(connection) }

        var outputCount: UInt32 = 2
        var output: [UInt64] = [0, 0]

        let result = IOConnectCallMethod(connection, 0, nil, 0, nil, 0, &output, &outputCount, nil, nil)

        guard result == KERN_SUCCESS else { return nil }

        let rawLux = output[0]

        if rawLux == UInt64.max || rawLux == UInt64.max - 1 {
            return nil
        }

        let lmuLux = ALSReader.lmuToLux(rawLux)
        let lux = LuxCalibrator.calibrate(lmuLux, source: .lmuController)
        return ALSReading(lux: lux, source: .lmuController)
    }

    private func readDisplayServices() -> ALSReading? {
        guard let raw = PrivateAPILoader.displayServicesAggregatedLux() else {
            return nil
        }
        guard raw >= 0 else { return nil }
        let lux = LuxCalibrator.calibrate(raw, source: .displayServices)
        return ALSReading(lux: lux, source: .displayServices)
    }

    public static func lmuToLux(_ raw: UInt64) -> Double {
        let scaled = Double(raw) / 100000.0
        let lux = ceil((-3e-7 * pow(scaled, 4)) + (2.6e-4 * pow(scaled, 3)) + (-3.4e-2 * pow(scaled, 2)) + 3.9 * scaled - 0.19)
        return max(0, lux)
    }
}

public extension IOKitBridging {
    static func readPropertyDouble(_ service: io_service_t, _ key: String) -> Double? {
        guard let result = IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0) else {
            return nil
        }
        let value = result.takeRetainedValue()
        if let d = value as? Double { return d }
        if let n = value as? NSNumber { return n.doubleValue }
        return nil
    }
}
