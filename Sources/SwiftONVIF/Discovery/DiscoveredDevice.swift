import Foundation

/// A device found via WS-Discovery probe.
///
/// The `xAddrs` field contains the ONVIF device service URL (e.g. `http://192.168.1.100/onvif/device_service`).
/// Use this URL to create an `ONVIFCamera` connection.
public struct DiscoveredDevice: Sendable, Identifiable {
    /// Unique identifier from the WS-Discovery response (EndpointReference Address).
    public let id: String

    /// Display name if provided in the ProbeMatch scopes.
    public let name: String?

    /// ONVIF device service endpoint URL(s). Typically one URL.
    public let xAddrs: [URL]

    /// Hardware identifier from scopes (e.g. manufacturer/model).
    public let hardware: String?

    /// Scopes advertised by the device (URIs describing device type, location, etc.).
    public let scopes: [String]

    public init(id: String, name: String?, xAddrs: [URL], hardware: String?, scopes: [String]) {
        self.id = id
        self.name = name
        self.xAddrs = xAddrs
        self.hardware = hardware
        self.scopes = scopes
    }
}
