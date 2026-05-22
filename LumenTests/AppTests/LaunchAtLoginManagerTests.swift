import XCTest
import ServiceManagement
@testable import Lumen

enum MockError: Error, Equatable {
    case failure
}

final class MockSMAppService: SMAppServiceProtocol {
    var status: SMAppService.Status = .notRegistered
    var registerCallCount = 0
    var unregisterCallCount = 0
    var throwOnRegister: Error?
    var throwOnUnregister: Error?

    func register() throws {
        registerCallCount += 1
        if let error = throwOnRegister { throw error }
        status = .enabled
    }

    func unregister() throws {
        unregisterCallCount += 1
        if let error = throwOnUnregister { throw error }
        status = .notRegistered
    }
}

final class LaunchAtLoginManagerTests: XCTestCase {
    private var service: MockSMAppService!
    private var manager: LaunchAtLoginManager!

    override func setUp() {
        super.setUp()
        service = MockSMAppService()
        manager = LaunchAtLoginManager(service: service)
    }

    override func tearDown() {
        manager = nil
        service = nil
        super.tearDown()
    }

    func testIsEnabled_whenNotRegistered_returnsFalse() {
        service.status = .notRegistered
        XCTAssertFalse(manager.isEnabled)
    }

    func testIsEnabled_whenEnabled_returnsTrue() {
        service.status = .enabled
        XCTAssertTrue(manager.isEnabled)
    }

    func testEnable_callsRegister() throws {
        try manager.enable()
        XCTAssertEqual(service.registerCallCount, 1)
        XCTAssertTrue(manager.isEnabled)
    }

    func testEnable_whenRegisterThrows_propagatesError() {
        service.throwOnRegister = MockError.failure
        XCTAssertThrowsError(try manager.enable()) { error in
            XCTAssertEqual(error as? MockError, .failure)
        }
        XCTAssertEqual(service.registerCallCount, 1)
    }

    func testDisable_callsUnregister() throws {
        service.status = .enabled
        try manager.disable()
        XCTAssertEqual(service.unregisterCallCount, 1)
        XCTAssertFalse(manager.isEnabled)
    }

    func testDisable_whenUnregisterThrows_propagatesError() {
        service.status = .enabled
        service.throwOnUnregister = MockError.failure
        XCTAssertThrowsError(try manager.disable()) { error in
            XCTAssertEqual(error as? MockError, .failure)
        }
        XCTAssertEqual(service.unregisterCallCount, 1)
    }

    func testBind_syncsInitialState_enabled() {
        let settings = SettingsStore()
        settings.launchAtLogin = true
        manager.bind(to: settings)
        XCTAssertEqual(service.registerCallCount, 1)
        XCTAssertTrue(manager.isEnabled)
    }

    func testBind_syncsInitialState_disabled() {
        service.status = .enabled
        let settings = SettingsStore()
        settings.launchAtLogin = false
        manager.bind(to: settings)
        XCTAssertEqual(service.unregisterCallCount, 1)
        XCTAssertFalse(manager.isEnabled)
    }

    func testBind_whenAlreadyInSync_doesNothing() throws {
        service.status = .notRegistered
        let settings = SettingsStore()
        settings.launchAtLogin = false
        manager.bind(to: settings)
        XCTAssertEqual(service.registerCallCount, 0)
        XCTAssertEqual(service.unregisterCallCount, 0)
    }

    func testIsEnabled_whenRequiresApproval_returnsFalse() {
        service.status = .requiresApproval
        XCTAssertFalse(manager.isEnabled)
    }

    func testIsEnabled_whenNotFound_returnsFalse() {
        service.status = .notFound
        XCTAssertFalse(manager.isEnabled)
    }
}
