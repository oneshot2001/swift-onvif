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
/// let info = try await camera.device.getDeviceInformation()
/// try await camera.initialize()
/// let profiles = try await camera.media.getProfiles()
/// ```
public final class ONVIFCamera {

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

    /// Device capabilities, populated after `initialize()`.
    public private(set) var capabilities: Capabilities?

    private let client: SOAPClient

    /// Creates an ONVIF camera connection.
    ///
    /// After creation, the `device` service is immediately available. Call `initialize()` to
    /// discover which other services the camera supports and populate `media`, `ptz`, etc.
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
    /// Calls `GetCapabilities` to discover which services the camera supports.
    /// After this call, `media`, `ptz`, `imaging`, and `events` will be populated.
    public func initialize() async throws {
        let caps = try await device.getCapabilities()
        self.capabilities = caps

        // Initialize Media service
        if let mediaCap = caps.media {
            self.media = MediaService(client: client, serviceURL: mediaCap.xAddr)
        } else {
            // Fallback: construct media URL from device URL pattern
            let mediaURL = URL(string: "http://\(host):\(port)/onvif/media_service")!
            self.media = MediaService(client: client, serviceURL: mediaURL)
        }

        // Initialize PTZ if supported
        if let ptzCap = caps.ptz {
            self.ptz = PTZService(client: client, serviceURL: ptzCap.xAddr)
        }

        // Initialize Imaging if supported
        if let imgCap = caps.imaging {
            self.imaging = ImagingService(client: client, serviceURL: imgCap.xAddr)
        }

        // Initialize Events if supported
        if let evtCap = caps.events {
            self.events = EventService(client: client, serviceURL: evtCap.xAddr)
        }

        // Try to find Media2 via GetServices (not in GetCapabilities)
        if let services = try? await device.getServices() {
            for service in services {
                if service.namespace.contains("ver20/media") {
                    self.media2 = Media2Service(client: client, serviceURL: service.xAddr)
                    break
                }
            }
        }
    }
}
