import Foundation

/// ONVIF Media Service (ver10/media/wsdl).
///
/// Provides access to media profiles, stream URIs, and snapshot URIs.
/// This is the most commonly used service after DeviceService.
///
/// Reference: ONVIF Media Service Specification.
public final class MediaService: Sendable {

    private let client: SOAPClient
    private let serviceURL: URL

    init(client: SOAPClient, serviceURL: URL) {
        self.client = client
        self.serviceURL = serviceURL
    }

    /// Retrieves all media profiles configured on the device.
    ///
    /// A media profile binds a video source, encoder, PTZ, and analytics configuration together.
    /// Most cameras have at least one pre-configured profile.
    ///
    /// ONVIF operation: `GetProfiles`
    public func getProfiles() async throws -> [MediaProfile] {
        // TODO: v0.2.0 — Implement GetProfiles SOAP call
        fatalError("Not yet implemented")
    }

    /// Retrieves the RTSP stream URI for a given media profile.
    ///
    /// ONVIF operation: `GetStreamUri`
    ///
    /// - Parameter profileToken: The token of the media profile to get the stream for.
    /// - Returns: A `StreamURI` containing the RTSP URL.
    public func getStreamURI(profileToken: String) async throws -> StreamURI {
        // TODO: v0.2.0 — Implement GetStreamUri SOAP call
        fatalError("Not yet implemented")
    }

    /// Retrieves the HTTP snapshot URI for a given media profile.
    ///
    /// ONVIF operation: `GetSnapshotUri`
    ///
    /// - Parameter profileToken: The token of the media profile.
    /// - Returns: A `StreamURI` containing the HTTP snapshot URL.
    public func getSnapshotURI(profileToken: String) async throws -> StreamURI {
        // TODO: v0.2.0 — Implement GetSnapshotUri SOAP call
        fatalError("Not yet implemented")
    }

    /// Retrieves video encoder configurations for a given profile.
    ///
    /// ONVIF operation: `GetVideoEncoderConfigurations`
    public func getVideoEncoderConfigurations() async throws -> [VideoEncoder] {
        // TODO: v0.2.0
        fatalError("Not yet implemented")
    }

    /// Retrieves a specific video encoder configuration.
    ///
    /// ONVIF operation: `GetVideoEncoderConfiguration`
    public func getVideoEncoderConfiguration(token: String) async throws -> VideoEncoder {
        // TODO: v0.2.0
        fatalError("Not yet implemented")
    }
}
