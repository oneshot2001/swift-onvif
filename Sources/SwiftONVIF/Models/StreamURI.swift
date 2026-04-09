import Foundation

/// A stream or snapshot URI returned by the Media service.
public struct StreamURI: Sendable {
    /// The URI (RTSP for streams, HTTP for snapshots).
    public let uri: URL

    /// Whether the URI is valid indefinitely or will expire.
    public let invalidAfterConnect: Bool

    /// Whether reconnection is required after disconnect.
    public let invalidAfterReboot: Bool

    /// Timeout duration, if applicable.
    public let timeout: Duration?

    public init(uri: URL, invalidAfterConnect: Bool = false, invalidAfterReboot: Bool = false, timeout: Duration? = nil) {
        self.uri = uri
        self.invalidAfterConnect = invalidAfterConnect
        self.invalidAfterReboot = invalidAfterReboot
        self.timeout = timeout
    }
}
