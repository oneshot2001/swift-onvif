import Foundation

/// Device capabilities returned by `GetCapabilities`.
///
/// Contains URLs for each supported ONVIF service. A nil URL means
/// the device does not support that service.
public struct Capabilities: Sendable {
    public let device: ServiceCapability?
    public let media: ServiceCapability?
    public let ptz: ServiceCapability?
    public let imaging: ServiceCapability?
    public let events: ServiceCapability?
    public let analytics: ServiceCapability?

    public init(
        device: ServiceCapability? = nil,
        media: ServiceCapability? = nil,
        ptz: ServiceCapability? = nil,
        imaging: ServiceCapability? = nil,
        events: ServiceCapability? = nil,
        analytics: ServiceCapability? = nil
    ) {
        self.device = device
        self.media = media
        self.ptz = ptz
        self.imaging = imaging
        self.events = events
        self.analytics = analytics
    }
}

/// A single service's capability info.
public struct ServiceCapability: Sendable {
    public let xAddr: URL

    public init(xAddr: URL) {
        self.xAddr = xAddr
    }
}
