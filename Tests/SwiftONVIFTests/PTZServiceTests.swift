import XCTest
@testable import SwiftONVIF

final class PTZServiceTests: XCTestCase {

    func testGetPresetsParsing() throws {
        // TODO: v0.3.0 — Parse GetPresetsResponse and verify:
        // - Preset tokens are present
        // - Preset names are present (if set)
        // - Position coordinates are valid
        XCTFail("Not yet implemented")
    }

    func testContinuousMoveRequest() throws {
        // TODO: v0.3.0 — Verify ContinuousMove SOAP request XML contains:
        // - Correct profile token
        // - PanTilt velocity x/y values
        // - Zoom velocity
        XCTFail("Not yet implemented")
    }

    func testStopRequest() throws {
        // TODO: v0.3.0 — Verify Stop SOAP request XML
        XCTFail("Not yet implemented")
    }

    func testPTZSpeedClamping() throws {
        // TODO: v0.3.0 — Verify that velocity values outside -1.0...1.0 are handled
        XCTFail("Not yet implemented")
    }

    func testGetStatusParsing() throws {
        // TODO: v0.3.0 — Parse GetStatusResponse, verify position and move state
        XCTFail("Not yet implemented")
    }
}
