import XCTest
@testable import Lumen

final class ALSReadingTests: XCTestCase {
    func testALSReadingDefaults() {
        let reading = ALSReading(lux: 10.0, source: .hid)
        XCTAssertEqual(reading.lux, 10.0)
        XCTAssertEqual(reading.source, .hid)
    }

    func testALSReadingEquatable() {
        let now = Date()
        let a = ALSReading(lux: 10.0, timestamp: now, source: .hid)
        let b = ALSReading(lux: 10.0, timestamp: now, source: .hid)
        XCTAssertEqual(a, b)
    }

    func testALSReadingSourceCases() {
        XCTAssertEqual(ALSSource.allCases.count, 4)
        XCTAssertEqual(ALSSource.hid.rawValue, "HID")
        XCTAssertEqual(ALSSource.ioRegistry.rawValue, "IORegistry")
        XCTAssertEqual(ALSSource.lmuController.rawValue, "LMU")
        XCTAssertEqual(ALSSource.displayServices.rawValue, "DisplayServices")
    }
}
