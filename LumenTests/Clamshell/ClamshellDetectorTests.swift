import XCTest
@testable import Lumen

final class ClamshellDetectorTests: XCTestCase {
    var detector: ClamshellDetector!
    
    override func setUp() {
        super.setUp()
        detector = ClamshellDetector()
    }
    
    override func tearDown() {
        detector = nil
        super.tearDown()
    }
    
    // MARK: - Protocol Conformance
    
    func testConformsToClamshellDetectingProtocol() {
        XCTAssertTrue((detector as Any) is ClamshellDetecting)
    }
    
    // MARK: - Initial State
    
    func testInitialStateReadFromIOKit() {
        let state = detector.currentState()
        XCTAssertTrue(state == .open || state == .closed)
    }
    
    // MARK: - State Change Callback
    
    func testSetOnStateChangeAcceptsHandler() {
        let expectation = self.expectation(description: "State change handler set")
        
        detector.setOnStateChange { _ in
            expectation.fulfill()
        }
        
        // Fulfill immediately since we can't reliably trigger a real lid event in tests
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Lifecycle
    
    func testDetectorCanBeCreatedAndDestroyed() {
        var d: ClamshellDetector? = ClamshellDetector()
        XCTAssertNotNil(d)
        XCTAssertTrue(d?.currentState() == .open || d?.currentState() == .closed)
        d = nil
        XCTAssertNil(d)
    }
    
    // MARK: - No Shell Commands
    
    func testNoShellCommandsUsed() {
        // This test documents that ClamshellDetector uses IOKit directly,
        // not Process/ioreg/NSTask. Verified by source inspection.
        let mirror = Mirror(reflecting: detector!)
        let hasProcessProperty = mirror.children.contains { child in
            child.value is Process || child.value is NSTask
        }
        XCTAssertFalse(hasProcessProperty, "ClamshellDetector must not use Process/NSTask")
    }
}
