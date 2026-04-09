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
            """
            <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" \
            xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">\
            <wsse:UsernameToken>\
            <wsse:Username>\(username)</wsse:Username>\
            <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest">\(passwordDigest)</wsse:Password>\
            <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">\(nonce)</wsse:Nonce>\
            <wsu:Created>\(created)</wsu:Created>\
            </wsse:UsernameToken>\
            </wsse:Security>
            """
        }
    }

    /// Generates a UsernameToken with password digest authentication.
    ///
    /// - Parameter credential: The username and password for the device.
    /// - Returns: A `UsernameToken` with digest, nonce, and timestamp.
    public static func usernameToken(credential: ONVIFCredential) -> UsernameToken {
        // 1. Generate random 16-byte nonce
        var nonceBytes = [UInt8](repeating: 0, count: 16)
        for i in 0..<16 {
            nonceBytes[i] = UInt8.random(in: 0...255)
        }
        let nonceData = Data(nonceBytes)
        let nonceBase64 = nonceData.base64EncodedString()

        // 2. Create ISO 8601 timestamp
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let created = formatter.string(from: Date())

        // 3. Compute SHA1(nonce + created + password)
        // The digest is: Base64(SHA1(NonceRawBytes + Created + Password))
        var digestInput = Data()
        digestInput.append(nonceData)
        digestInput.append(Data(created.utf8))
        digestInput.append(Data(credential.password.utf8))

        let hash = Insecure.SHA1.hash(data: digestInput)
        let passwordDigest = Data(hash).base64EncodedString()

        return UsernameToken(
            username: credential.username,
            passwordDigest: passwordDigest,
            nonce: nonceBase64,
            created: created
        )
    }

    /// Generates a UsernameToken with a known nonce and timestamp (for testing).
    internal static func usernameToken(
        credential: ONVIFCredential,
        nonce: Data,
        created: String
    ) -> UsernameToken {
        let nonceBase64 = nonce.base64EncodedString()

        var digestInput = Data()
        digestInput.append(nonce)
        digestInput.append(Data(created.utf8))
        digestInput.append(Data(credential.password.utf8))

        let hash = Insecure.SHA1.hash(data: digestInput)
        let passwordDigest = Data(hash).base64EncodedString()

        return UsernameToken(
            username: credential.username,
            passwordDigest: passwordDigest,
            nonce: nonceBase64,
            created: created
        )
    }
}
