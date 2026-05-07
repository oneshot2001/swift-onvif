import Foundation
import XMLCoder

/// ONVIF Device Management Service (ver10/device/wsdl).
///
/// Provides access to device information, capabilities, and system settings.
/// This is the foundational service -- every ONVIF device supports it.
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
        let body = "<tds:GetDeviceInformation/>"
        let data = try await client.send(
            to: serviceURL,
            action: "http://www.onvif.org/ver10/device/wsdl/GetDeviceInformation",
            body: body
        )

        guard let bodyXML = SOAPClient.extractBody(from: data) else {
            throw ONVIFError.invalidResponse
        }

        return try DeviceService.parseDeviceInformation(from: bodyXML)
    }

    /// Retrieves device capabilities (which services are supported and their URLs).
    ///
    /// ONVIF operation: `GetCapabilities`
    public func getCapabilities() async throws -> Capabilities {
        let body = "<tds:GetCapabilities><tds:Category>All</tds:Category></tds:GetCapabilities>"
        let data = try await client.send(
            to: serviceURL,
            action: "http://www.onvif.org/ver10/device/wsdl/GetCapabilities",
            body: body
        )

        guard let bodyXML = SOAPClient.extractBody(from: data) else {
            throw ONVIFError.invalidResponse
        }

        return try DeviceService.parseCapabilities(from: bodyXML)
    }

    /// Retrieves the list of services supported by the device with their versions and URLs.
    ///
    /// ONVIF operation: `GetServices`
    /// Preferred over `getCapabilities()` for ONVIF 2.0+ devices.
    public func getServices(includeCapability: Bool = false) async throws -> [ServiceEntry] {
        let includeStr = includeCapability ? "true" : "false"
        let body = "<tds:GetServices><tds:IncludeCapability>\(includeStr)</tds:IncludeCapability></tds:GetServices>"
        let data = try await client.send(
            to: serviceURL,
            action: "http://www.onvif.org/ver10/device/wsdl/GetServices",
            body: body
        )

        guard let bodyXML = SOAPClient.extractBody(from: data) else {
            throw ONVIFError.invalidResponse
        }

        return DeviceService.parseServices(from: bodyXML)
    }

    /// Retrieves device scopes (location, hardware, name URIs).
    ///
    /// ONVIF operation: `GetScopes`
    public func getScopes() async throws -> [String] {
        let body = "<tds:GetScopes/>"
        let data = try await client.send(
            to: serviceURL,
            action: "http://www.onvif.org/ver10/device/wsdl/GetScopes",
            body: body
        )

        guard let bodyXML = SOAPClient.extractBody(from: data) else {
            throw ONVIFError.invalidResponse
        }

        return DeviceService.parseScopes(from: bodyXML)
    }

    /// Retrieves the system date and time from the device.
    ///
    /// ONVIF operation: `GetSystemDateAndTime`
    /// Useful for clock sync validation before WS-Security authentication.
    public func getSystemDateAndTime() async throws -> SystemDateTime {
        let body = "<tds:GetSystemDateAndTime/>"
        let data = try await client.send(
            to: serviceURL,
            action: "http://www.onvif.org/ver10/device/wsdl/GetSystemDateAndTime",
            body: body
        )

        guard let bodyXML = SOAPClient.extractBody(from: data) else {
            throw ONVIFError.invalidResponse
        }

        return DeviceService.parseSystemDateTime(from: bodyXML)
    }

    // MARK: - XML Parsing

    /// Parses GetDeviceInformationResponse XML.
    static func parseDeviceInformation(from xml: String) throws -> DeviceInfo {
        let extract = { (name: String) -> String in
            Self.extractValue(named: name, from: xml) ?? ""
        }
        return DeviceInfo(
            manufacturer: extract("Manufacturer"),
            model: extract("Model"),
            firmwareVersion: extract("FirmwareVersion"),
            serialNumber: extract("SerialNumber"),
            hardwareId: extract("HardwareId")
        )
    }

    /// Parses GetCapabilitiesResponse XML.
    static func parseCapabilities(from xml: String) throws -> Capabilities {
        let wrapperOpen = "<(?:[a-zA-Z][a-zA-Z0-9_]*:)?GetCapabilitiesResponse(?:\\s[^>]*)?>"
        let wrapperClose = "</(?:[a-zA-Z][a-zA-Z0-9_]*:)?GetCapabilitiesResponse>"
        guard xml.range(of: wrapperOpen, options: .regularExpression) != nil,
              xml.range(of: wrapperClose, options: .regularExpression) != nil else {
            throw ONVIFError.invalidResponse
        }

        func parseService(_ name: String) -> ServiceCapability? {
            let escaped = NSRegularExpression.escapedPattern(for: name)
            let openPattern = "<(?:[a-zA-Z][a-zA-Z0-9_]*:)?\(escaped)(?:\\s[^>]*)?>"
            let closePattern = "</(?:[a-zA-Z][a-zA-Z0-9_]*:)?\(escaped)>"

            guard let openRegex = try? NSRegularExpression(pattern: openPattern),
                  let closeRegex = try? NSRegularExpression(pattern: closePattern) else {
                return nil
            }

            let fullRange = NSRange(xml.startIndex..., in: xml)
            guard let openMatch = openRegex.firstMatch(in: xml, range: fullRange),
                  let openRange = Range(openMatch.range, in: xml) else {
                return nil
            }

            let afterOpen = openRange.upperBound
            let closeSearch = NSRange(afterOpen..<xml.endIndex, in: xml)
            guard let closeMatch = closeRegex.firstMatch(in: xml, range: closeSearch),
                  let closeRange = Range(closeMatch.range, in: xml) else {
                return nil
            }

            let section = String(xml[afterOpen..<closeRange.lowerBound])
            guard let xAddr = Self.extractValue(named: "XAddr", from: section),
                  let url = URL(string: xAddr) else {
                return nil
            }
            return ServiceCapability(xAddr: url)
        }

        return Capabilities(
            device: parseService("Device"),
            media: parseService("Media"),
            ptz: parseService("PTZ"),
            imaging: parseService("Imaging"),
            events: parseService("Events"),
            analytics: parseService("Analytics")
        )
    }

    /// Parses GetServicesResponse XML.
    static func parseServices(from xml: String) -> [ServiceEntry] {
        var services: [ServiceEntry] = []

        // Split by Service elements
        var searchRange = xml.startIndex..<xml.endIndex
        while let serviceStart = xml.range(of: "Service>", range: searchRange) {
            // Avoid closing tags
            let prefix = xml[xml.index(before: serviceStart.lowerBound)..<serviceStart.lowerBound]
            if prefix == "/" {
                searchRange = serviceStart.upperBound..<xml.endIndex
                continue
            }

            guard let serviceEnd = xml.range(of: "Service>", range: serviceStart.upperBound..<xml.endIndex) else { break }
            let section = String(xml[serviceStart.upperBound..<serviceEnd.lowerBound])

            let namespace = Self.extractValue(named: "Namespace", from: section) ?? ""
            let xAddr = Self.extractValue(named: "XAddr", from: section) ?? ""
            let major = Int(Self.extractValue(named: "Major", from: section) ?? "0") ?? 0
            let minor = Int(Self.extractValue(named: "Minor", from: section) ?? "0") ?? 0

            if let url = URL(string: xAddr) {
                services.append(ServiceEntry(
                    namespace: namespace,
                    xAddr: url,
                    version: ServiceVersion(major: major, minor: minor)
                ))
            }

            searchRange = serviceEnd.upperBound..<xml.endIndex
        }

        return services
    }

    /// Parses GetScopesResponse XML.
    static func parseScopes(from xml: String) -> [String] {
        var scopes: [String] = []
        var searchRange = xml.startIndex..<xml.endIndex

        while let start = xml.range(of: "ScopeItem>", range: searchRange) {
            let prefix = xml[xml.index(before: start.lowerBound)..<start.lowerBound]
            if prefix == "/" {
                searchRange = start.upperBound..<xml.endIndex
                continue
            }

            let closingPatterns = ["</tds:ScopeItem>", "</tt:ScopeItem>", "</ScopeItem>"]
            for closing in closingPatterns {
                if let end = xml.range(of: closing, range: start.upperBound..<xml.endIndex) {
                    let scope = String(xml[start.upperBound..<end.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !scope.isEmpty { scopes.append(scope) }
                    searchRange = end.upperBound..<xml.endIndex
                    break
                }
            }

            // Safety: advance past current match to avoid infinite loop
            if searchRange.lowerBound <= start.upperBound {
                searchRange = start.upperBound..<xml.endIndex
            }
        }

        return scopes
    }

    /// Parses GetSystemDateAndTimeResponse XML.
    static func parseSystemDateTime(from xml: String) -> SystemDateTime {
        let dateTimeType = Self.extractValue(named: "DateTimeType", from: xml) ?? "Manual"
        let dst = Self.extractValue(named: "DaylightSavings", from: xml) == "true"

        // Extract UTC date/time components
        let year = Int(Self.extractValue(named: "Year", from: xml) ?? "") ?? 0
        let month = Int(Self.extractValue(named: "Month", from: xml) ?? "") ?? 0
        let day = Int(Self.extractValue(named: "Day", from: xml) ?? "") ?? 0
        let hour = Int(Self.extractValue(named: "Hour", from: xml) ?? "") ?? 0
        let minute = Int(Self.extractValue(named: "Minute", from: xml) ?? "") ?? 0
        let second = Int(Self.extractValue(named: "Second", from: xml) ?? "") ?? 0

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        let date = calendar.date(from: components)

        return SystemDateTime(dateTimeType: dateTimeType, daylightSavings: dst, utcDateTime: date)
    }

    // MARK: - Utility

    /// Extracts text content from an XML element, handling namespace prefixes.
    static func extractValue(named name: String, from xml: String) -> String? {
        // Match <Name>, <prefix:Name>, <Name attr="...">
        let patterns = [
            "<\(name)>([^<]+)</\(name)>",
            "<[a-zA-Z]+:\(name)>([^<]+)</[a-zA-Z]+:\(name)>",
            "<\(name)[^>]*>([^<]+)</\(name)>",
            "<[a-zA-Z]+:\(name)[^>]*>([^<]+)</[a-zA-Z]+:\(name)>"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: xml, range: NSRange(xml.startIndex..., in: xml)),
               let valueRange = Range(match.range(at: 1), in: xml) {
                return String(xml[valueRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
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
    public let dateTimeType: String
    public let daylightSavings: Bool
    public let utcDateTime: Date?

    public init(dateTimeType: String, daylightSavings: Bool, utcDateTime: Date?) {
        self.dateTimeType = dateTimeType
        self.daylightSavings = daylightSavings
        self.utcDateTime = utcDateTime
    }
}
