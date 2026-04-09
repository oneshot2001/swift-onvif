import XCTest
@testable import SwiftONVIF

final class AuthTests: XCTestCase {

    func testUsernameTokenDigest() throws {
        // TODO: v0.1.0 — Test WS-Security UsernameToken generation
        // Given a known username, password, nonce, and timestamp,
        // verify the digest matches the expected SHA1(nonce + created + password) value.
        //
        // Known test vector:
        //   Username: "admin"
        //   Password: "password123"
        //   Nonce (base64): known value
        //   Created: "2026-04-09T12:00:00Z"
        //   Expected PasswordDigest: computed from above
        XCTFail("Not yet implemented")
    }

    func testNonceIsRandom() throws {
        // TODO: v0.1.0 — Generate two tokens and verify nonces differ
        XCTFail("Not yet implemented")
    }

    func testTimestampFormat() throws {
        // TODO: v0.1.0 — Verify Created timestamp is valid ISO 8601 UTC format
        XCTFail("Not yet implemented")
    }

    func testSecurityXMLOutput() throws {
        // TODO: v0.1.0 — Verify the generated XML contains all required WS-Security elements:
        // <wsse:Security>
        //   <wsse:UsernameToken>
        //     <wsse:Username>
        //     <wsse:Password Type="...#PasswordDigest">
        //     <wsse:Nonce EncodingType="...#Base64Binary">
        //     <wsu:Created>
        XCTFail("Not yet implemented")
    }
}
