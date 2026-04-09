import Foundation
import CryptoKit

/// Generates WS-Security UsernameToken headers for ONVIF SOAP requests.
///
/// ONVIF uses WS-Security with a password digest:
///   `PasswordDigest = Base64(SHA1(Nonce + Created + Password))`
///
/// The nonce is a random value, and Created is an ISO 8601 timestamp.
/// This prevents replay attacks and avoids sending passwords in cleartext.
///
/// Usage:
/// ```swift
/// let token = WSSecurity.usernameToken(credential: cred)
/// // Insert token.header into SOAP envelope's <Security> element
/// ```
public enum WSSecurity {

    /// A generated UsernameToken ready for insertion into a SOAP Security header.
    public struct UsernameToken: Sendable {
        public let username: String
        public let passwordDigest: String
        public let nonce: String
        public let created: String

        /// Returns the full `<wsse:Security>` XML block for embedding in a SOAP header.
        public var xmlElement: String {
            // TODO: v0.1.0 — Return properly formatted WS-Security XML
            fatalError("Not yet implemented")
        }
    }

    /// Generates a UsernameToken with password digest authentication.
    ///
    /// - Parameter credential: The username and password for the device.
    /// - Returns: A `UsernameToken` with digest, nonce, and timestamp.
    public static func usernameToken(credential: ONVIFCredential) -> UsernameToken {
        // TODO: v0.1.0 — Implement WS-Security UsernameToken digest
        // 1. Generate random 16-byte nonce
        // 2. Create ISO 8601 timestamp (e.g. "2026-04-09T12:00:00Z")
        // 3. Compute SHA1(nonce + created + password) — use CryptoKit Insecure.SHA1
        // 4. Base64 encode the digest and the nonce
        fatalError("Not yet implemented")
    }
}
