import Foundation

/// ONVIF Device Management Service (ver10/device/wsdl).
///
/// Provides access to device information, capabilities, and system settings.
/// This is the foundational service — every ONVIF device supports it.
///
/// Reference: ONVIF Core Specification, Section 8.
public final class DeviceService: Sendable {

    private let client: SOAPClient
    private let serviceURL: URL

    init(client: SOAPClient, serviceURL: URL) {
        self.client = client
        self.serviceURL = serviceURL
    }

    /// Retrieves basic device information (manufacturer, model, firmware, serial number).
    ///
    /// ONVIF operation: `GetDeviceInformation`
    public func getDeviceInformation() async throws -> DeviceInfo {
        // TODO: v0.1.0 — Implement GetDeviceInformation SOAP call
        fatalError("Not yet implemented")
    }

    /// Retrieves device capabilities (which services are supported and their URLs).
    ///
    /// ONVIF operation: `GetCapabilities`
    public func getCapabilities() async throws -> Capabilities {
        // TODO: v0.1.0 — Implement GetCapabilities SOAP call
        fatalError("Not yet implemented")
    }

    /// Retrieves the list of services supported by the device with their versions and URLs.
    ///
    /// ONVIF operation: `GetServices`
    /// Preferred over `getCapabilities()` for ONVIF 2.0+ devices.
    public func getServices(includeCapability: Bool = false) async throws -> [ServiceEntry] {
        // TODO: v0.1.0 — Implement GetServices SOAP call
        fatalError("Not yet implemented")
    }

    /// Retrieves device scopes (location, hardware, name URIs).
    ///
    /// ONVIF operation: `GetScopes`
    public func getScopes() async throws -> [String] {
        // TODO: v0.2.0
        fatalError("Not yet implemented")
    }

    /// Retrieves the system date and time from the device.
    ///
    /// ONVIF operation: `GetSystemDateAndTime`
    /// Useful for clock sync validation before WS-Security authentication.
    public func getSystemDateAndTime() async throws -> SystemDateTime {
        // TODO: v0.1.0 — Implement (needed for auth clock sync)
        fatalError("Not yet implemented")
    }
}

/// Entry from GetServices response.
public struct ServiceEntry: Sendable {
    public let namespace: String
    public let xAddr: URL
    public let version: ServiceVersion

    public init(namespace: String, xAddr: URL, version: ServiceVersion) {
        self.namespace = namespace
        self.xAddr = xAddr
        self.version = version
    }
}

/// ONVIF service version (major.minor).
public struct ServiceVersion: Sendable {
    public let major: Int
    public let minor: Int

    public init(major: Int, minor: Int) {
        self.major = major
        self.minor = minor
    }
}

/// System date and time from the device.
public struct SystemDateTime: Sendable {
    public let dateTimeType: String // "Manual" or "NTP"
    public let daylightSavings: Bool
    public let utcDateTime: Date?

    public init(dateTimeType: String, daylightSavings: Bool, utcDateTime: Date?) {
        self.dateTimeType = dateTimeType
        self.daylightSavings = daylightSavings
        self.utcDateTime = utcDateTime
    }
}
