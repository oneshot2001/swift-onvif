import XCTest
@testable import SwiftONVIF

final class MediaServiceTests: XCTestCase {

    func testGetProfilesParsing() throws {
        // Load the mock GetProfilesResponse XML fixture
        let fixtureURL = Bundle.module.url(forResource: "get-profiles-response", withExtension: "xml", subdirectory: "Fixtures")!
        let data = try Data(contentsOf: fixtureURL)

        // TODO: v0.2.0 — Parse and verify:
        // - At least one profile returned
        // - Profile token is non-empty
        // - Profile name is present
        // - VideoSourceConfiguration is present
        // - VideoEncoderConfiguration is present
        XCTFail("Not yet implemented")
    }

    func testGetStreamURIParsing() throws {
        // Load the mock GetStreamUriResponse XML fixture
        let fixtureURL = Bundle.module.url(forResource: "get-stream-uri-response", withExtension: "xml", subdirectory: "Fixtures")!
        let data = try Data(contentsOf: fixtureURL)

        // TODO: v0.2.0 — Parse and verify:
        // - URI starts with "rtsp://"
        // - URI is a valid URL
        XCTFail("Not yet implemented")
    }

    func testGetSnapshotURIParsing() throws {
        // TODO: v0.2.0 — Parse GetSnapshotUriResponse, verify HTTP URL
        XCTFail("Not yet implemented")
    }
}
