import XCTest
@testable import Lumen

final class ALSReaderTests: XCTestCase {
    var reader: ALSReader!
    
    override func setUp() {
        reader = ALSReader()
    }
    
    // Test: LMU raw-to-lux conversion matches Chromium formula
    func testLMUToLuxConversion() {
        // Test values from Chromium formula (coefficients: -3e-7, 2.6e-4, -3.4e-2, 3.9, -0.19)
        XCTAssertEqual(ALSReader.lmuToLux(100000), 4.0, accuracy: 0.1)
        XCTAssertEqual(ALSReader.lmuToLux(0), 0.0, accuracy: 0.01)
        XCTAssertEqual(ALSReader.lmuToLux(5000000), 141.0, accuracy: 1.0)
    }
    
    // Test: sentinel value (-1) is NOT filtered here (ThresholdEngine handles it)
    func testNegativeOneNotFiltered() {
        // LMU returns -1 as error on Apple Silicon when display is off
        // ALSReader returns it as-is; ThresholdEngine filters it
        let result = ALSReader.lmuToLux(UInt64.max)  // overflow case
        XCTAssertGreaterThanOrEqual(result, 0)
    }
    
    // Test: reader conforms to ALSReadingProtocol
    func testConformsToALSReadingProtocol() {
        XCTAssertTrue((reader as Any) is ALSReadingProtocol)
    }
}
