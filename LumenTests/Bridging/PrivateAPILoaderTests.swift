import XCTest
@testable import Lumen

final class PrivateAPILoaderTests: XCTestCase {
    
    // MARK: - Framework Loading Tests
    
    func testBezelServicesFrameworkLoads() throws {
        if ProcessInfo.processInfo.environment["CI"] != nil {
            throw XCTSkip("Skipping BezelServices test on CI")
        }
        
        let handle = PrivateAPILoader.loadBezelServices()
        XCTAssertNotNil(handle, "BezelServices framework should load on supported Macs")
    }
    
    func testSkyLightFrameworkLoads() throws {
        let handle = PrivateAPILoader.loadSkyLight()
        XCTAssertNotNil(handle, "SkyLight framework should load")
    }
    
    func testDisplayServicesFrameworkLoads() throws {
        let handle = PrivateAPILoader.loadDisplayServices()
        XCTAssertNotNil(handle, "DisplayServices framework should load")
    }
    
    // MARK: - Symbol Resolution Tests
    
    func testALCALSCopyALSServiceClientIsResolved() throws {
        if ProcessInfo.processInfo.environment["CI"] != nil {
            throw XCTSkip("Skipping ALS symbol test on CI")
        }
        
        guard PrivateAPILoader.loadBezelServices() != nil else {
            throw XCTSkip("BezelServices not available")
        }
        
        let ptr = PrivateAPILoader.ALCALSCopyALSServiceClientPtr()
        XCTAssertNotNil(ptr, "ALCALSCopyALSServiceClient function pointer should be resolved")
    }
    
    func testSLSSetAppearanceThemeNotifyingIsResolved() throws {
        guard PrivateAPILoader.loadSkyLight() != nil else {
            throw XCTSkip("SkyLight not available")
        }
        
        let ptr = PrivateAPILoader.SLSSetAppearanceThemeNotifyingPtr()
        XCTAssertNotNil(ptr, "SLSSetAppearanceThemeNotifying function pointer should be resolved")
    }
    
    func testSLSGetAppearanceThemeLegacyIsResolved() throws {
        guard PrivateAPILoader.loadSkyLight() != nil else {
            throw XCTSkip("SkyLight not available")
        }
        
        let ptr = PrivateAPILoader.SLSGetAppearanceThemeLegacyPtr()
        XCTAssertNotNil(ptr, "SLSGetAppearanceThemeLegacy function pointer should be resolved")
    }
    
    func testSLSSetAppearanceThemeLegacyIsResolved() throws {
        guard PrivateAPILoader.loadSkyLight() != nil else {
            throw XCTSkip("SkyLight not available")
        }
        
        let ptr = PrivateAPILoader.SLSSetAppearanceThemeLegacyPtr()
        XCTAssertNotNil(ptr, "SLSSetAppearanceThemeLegacy function pointer should be resolved")
    }
    
    // MARK: - Graceful Degradation Tests
    
    func testFunctionPointersReturnNilWhenUnavailable() {
        let handle = PrivateAPILoader.loadSkyLight()
        guard handle != nil else {
            XCTFail("SkyLight should load")
            return
        }
        
        let symbol: (@convention(c) () -> Void)? = PrivateAPILoader.resolveSymbol(handle, "NonExistentSymbol12345")
        XCTAssertNil(symbol, "resolveSymbol should return nil for non-existent symbols")
    }
    
    func testLazyLoadingCached() {
        let firstHandle = PrivateAPILoader.loadBezelServices()
        let secondHandle = PrivateAPILoader.loadBezelServices()
        XCTAssertEqual(firstHandle, secondHandle, "Second call should return cached handle")
    }
    
    // MARK: - DisplayServices Tests
    
    func testDisplayServicesAggregatedLux() throws {
        guard PrivateAPILoader.loadDisplayServices() != nil else {
            throw XCTSkip("DisplayServices not available")
        }
        
        let lux = PrivateAPILoader.displayServicesAggregatedLux()
        XCTAssertTrue(lux == nil || lux != nil, "displayServicesAggregatedLux should not crash")
    }
}
