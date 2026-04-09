import Foundation

/// Main entry point for interacting with an ONVIF camera.
///
/// `ONVIFCamera` provides a convenient, high-level API that wraps individual ONVIF services.
/// It handles service URL resolution, authentication, and provides access to all services
/// through typed properties.
///
/// Usage:
/// ```swift
/// let camera = ONVIFCamera(
///     host: "192.168.1.100",
///     credential: ONVIFCredential(username: "admin", password: "pass")
/// )
///
/// // Get device info
/// let info = try await camera.device.getDeviceInformation()
///
/// // Get media profiles and stream URIs
/// let profiles = try await camera.media.getProfiles()
/// let streamURI = try await camera.media.getStreamURI(profileToken: profiles[0].token)
///
/// // PTZ control (if supported)
/// if let ptz = camera.ptz {
///     try await ptz.continuousMove(
///         profileToken: profiles[0].token,
///         velocity: PTZSpeed(panTilt: Vector2D(x: 0.5, y: 0.0))
///     )
/// }
/// ```
public final class ONVIFCamera: Sendable {

    /// The camera's host address (IP or hostname).
    public let host: String

    /// The port number. Defaults to 80.
    public let port: Int

    /// The ONVIF device service endpoint path. Defaults to `/onvif/device_service`.
    public let path: String

    /// The credentials used for authentication.
    public let credential: ONVIFCredential?

    // MARK: - Services

    /// Device Management service. Always available.
    public let device: DeviceService

    /// Media service (ver10). Available after calling `initialize()`.
    public private(set) var media: MediaService!

    /// Media2 service (ver20). May be nil if device doesn't support it.
    public private(set) var media2: Media2Service?

    /// PTZ service. Nil if the device does not support PTZ.
    public private(set) var ptz: PTZService?

    /// Imaging service. Nil if the device does not support it.
    public private(set) var imaging: ImagingService?

    /// Event service. Nil if the device does not support it.
    public private(set) var events: EventService?

    private let client: SOAPClient

    /// Creates an ONVIF camera connection.
    ///
    /// After creation, call `initialize()` to discover available services and populate
    /// the `media`, `ptz`, `imaging`, and `events` properties.
    ///
    /// - Parameters:
    ///   - host: Camera IP address or hostname.
    ///   - port: ONVIF service port. Defaults to 80.
    ///   - path: Device service path. Defaults to `/onvif/device_service`.
    ///   - credential: Authentication credentials. Nil for unauthenticated access.
    public init(
        host: String,
        port: Int = 80,
        path: String = "/onvif/device_service",
        credential: ONVIFCredential? = nil
    ) {
        self.host = host
        self.port = port
        self.path = path
        self.credential = credential
        self.client = SOAPClient(credential: credential)

        let deviceURL = URL(string: "http://\(host):\(port)\(path)")!
        self.device = DeviceService(client: client, serviceURL: deviceURL)
    }

    /// Queries the device for supported services and initializes service properties.
    ///
    /// This calls `GetCapabilities` (or `GetServices` on newer devices) to discover
    /// which services the camera supports and their endpoint URLs. After this call,
    /// `media`, `ptz`, `imaging`, and `events` will be populated based on device capabilities.
    public func initialize() async throws {
        // TODO: v0.1.0 — Implement service discovery
        // 1. Call device.getCapabilities()
        // 2. For each capability with a non-nil xAddr, create the corresponding service
        // 3. Set media, media2, ptz, imaging, events properties
        fatalError("Not yet implemented")
    }
}
