import Foundation

/// ONVIF Media2 Service (ver20/media/wsdl).
///
/// The Media2 service is the successor to the original Media service.
/// It adds support for H.265 stream URIs and more flexible profile management.
/// Not all cameras support Media2 — check capabilities first.
///
/// Reference: ONVIF Media2 Service Specification.
public final class Media2Service: Sendable {

    private let client: SOAPClient
    private let serviceURL: URL

    init(client: SOAPClient, serviceURL: URL) {
        self.client = client
        self.serviceURL = serviceURL
    }

    /// Retrieves media profiles using the Media2 service.
    ///
    /// ONVIF operation: `GetProfiles` (ver20)
    public func getProfiles() async throws -> [MediaProfile] {
        // TODO: v0.4.0 — Implement Media2 GetProfiles
        fatalError("Not yet implemented")
    }

    /// Retrieves stream URI using the Media2 service.
    ///
    /// This version supports H.265 and other modern codecs.
    ///
    /// ONVIF operation: `GetStreamUri` (ver20)
    public func getStreamURI(profileToken: String, protocol: StreamProtocol = .rtsp) async throws -> StreamURI {
        // TODO: v0.4.0 — Implement Media2 GetStreamUri
        fatalError("Not yet implemented")
    }

    /// Retrieves snapshot URI using the Media2 service.
    ///
    /// ONVIF operation: `GetSnapshotUri` (ver20)
    public func getSnapshotURI(profileToken: String) async throws -> StreamURI {
        // TODO: v0.4.0
        fatalError("Not yet implemented")
    }
}

/// Stream transport protocol.
public enum StreamProtocol: String, Sendable {
    case rtsp = "RtspUnicast"
    case rtspMulticast = "RtspMulticast"
    case rtspOverHTTP = "RtspOverHttp"
}
