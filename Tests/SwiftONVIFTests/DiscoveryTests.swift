import XCTest
@testable import SwiftONVIF

final class DiscoveryTests: XCTestCase {

    func testProbeMatchParsing() throws {
        // Load the mock ProbeMatch XML fixture
        let fixtureURL = Bundle.module.url(forResource: "discovery-probe-match", withExtension: "xml", subdirectory: "Fixtures")!
        let data = try Data(contentsOf: fixtureURL)

        // TODO: v0.1.0 — Parse the ProbeMatch XML and verify:
        // - Device ID (EndpointReference Address)
        // - xAddrs URL(s)
        // - Scopes (manufacturer, model, hardware, name, location)
        // - Name extracted from scopes
        XCTFail("Not yet implemented")
    }

    func testMultipleProbeMatches() throws {
        // TODO: v0.1.0 — Test parsing a response with multiple ProbeMatch elements
        // (multiple cameras on the network)
        XCTFail("Not yet implemented")
    }

    func testEmptyProbeResponse() throws {
        // TODO: v0.1.0 — Test handling when no cameras respond (empty ProbeMatches)
        XCTFail("Not yet implemented")
    }

    func testScopesParsing() throws {
        // TODO: v0.1.0 — Test extracting name, hardware, location from ONVIF scope URIs
        // Scopes look like: "onvif://www.onvif.org/name/MyCamera"
        //                    "onvif://www.onvif.org/hardware/ModelX"
        XCTFail("Not yet implemented")
    }
}
