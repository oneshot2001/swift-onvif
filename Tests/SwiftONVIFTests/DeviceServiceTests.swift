import XCTest
@testable import SwiftONVIF

final class DeviceServiceTests: XCTestCase {

    func testGetDeviceInformationParsing() throws {
        // Load the mock GetDeviceInformationResponse XML fixture
        let fixtureURL = Bundle.module.url(forResource: "get-device-info-response", withExtension: "xml", subdirectory: "Fixtures")!
        let data = try Data(contentsOf: fixtureURL)

        // TODO: v0.1.0 — Parse and verify:
        // - manufacturer == "TestManufacturer"
        // - model == "TestModel-1000"
        // - firmwareVersion == "1.2.3"
        // - serialNumber == "ABCD1234567890"
        // - hardwareId == "HW-100"
        XCTFail("Not yet implemented")
    }

    func testGetCapabilitiesParsing() throws {
        // TODO: v0.1.0 — Parse GetCapabilitiesResponse and verify service URLs
        XCTFail("Not yet implemented")
    }

    func testSOAPFaultHandling() throws {
        // TODO: v0.1.0 — Verify SOAPFault is correctly parsed when device returns an error
        // Test with ter:NotAuthorized fault
        XCTFail("Not yet implemented")
    }
}
