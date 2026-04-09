import Foundation

/// Credentials for authenticating with an ONVIF device.
///
/// Most ONVIF cameras require WS-Security UsernameToken authentication.
/// Some operations (like discovery) work without credentials.
public struct ONVIFCredential: Sendable {
    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
