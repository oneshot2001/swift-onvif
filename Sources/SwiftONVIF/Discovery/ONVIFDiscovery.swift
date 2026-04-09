import Foundation
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

/// Discovers ONVIF-compliant cameras on the local network using WS-Discovery (SOAP-over-UDP multicast).
///
/// WS-Discovery sends a `Probe` message to the multicast address `239.255.255.250:3702`.
/// Cameras respond with `ProbeMatch` messages containing their ONVIF service endpoints.
///
/// Uses BSD sockets directly for reliable multicast send + unicast receive on the same port.
///
/// Usage:
/// ```swift
/// let discovery = ONVIFDiscovery()
/// let devices = try await discovery.probe(timeout: .seconds(5))
/// for device in devices {
///     print("\(device.name) at \(device.xAddrs)")
/// }
/// ```
public final class ONVIFDiscovery: Sendable {

    /// WS-Discovery multicast address.
    private static let multicastAddress = "239.255.255.250"
    private static let multicastPort: UInt16 = 3702

    public init() {}

    /// Sends a WS-Discovery Probe and collects responses until timeout.
    ///
    /// - Parameter timeout: How long to listen for responses. Default 5 seconds.
    /// - Returns: Array of discovered devices, deduplicated by endpoint reference.
    public func probe(timeout: Duration = .seconds(5)) async throws -> [DiscoveredDevice] {
        let messageID = UUID().uuidString

        let probeMessage = """
        <?xml version="1.0" encoding="UTF-8"?>
        <soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" \
        xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" \
        xmlns:d="http://schemas.xmlsoap.org/ws/2005/04/discovery" \
        xmlns:dn="http://www.onvif.org/ver10/network/wsdl">
        <soap:Header>
        <wsa:MessageID>uuid:\(messageID)</wsa:MessageID>
        <wsa:To>urn:schemas-xmlsoap-org:ws:2005:04:discovery</wsa:To>
        <wsa:Action>http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe</wsa:Action>
        </soap:Header>
        <soap:Body>
        <d:Probe><d:Types>dn:NetworkVideoTransmitter</d:Types></d:Probe>
        </soap:Body>
        </soap:Envelope>
        """

        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var devices: [String: DiscoveredDevice] = [:]

                // Create UDP socket
                let fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
                guard fd >= 0 else {
                    continuation.resume(returning: [])
                    return
                }

                defer { close(fd) }

                // Allow address reuse
                var reuse: Int32 = 1
                setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, socklen_t(MemoryLayout<Int32>.size))

                // Set receive timeout
                let timeoutSecs = Int(timeout.components.seconds)
                var tv = timeval(tv_sec: timeoutSecs, tv_usec: 0)
                setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))

                // Build multicast destination address
                var destAddr = sockaddr_in()
                destAddr.sin_family = sa_family_t(AF_INET)
                destAddr.sin_port = Self.multicastPort.bigEndian
                inet_pton(AF_INET, Self.multicastAddress, &destAddr.sin_addr)

                // Send probe
                let probeData = Array(probeMessage.utf8)
                let sent = withUnsafePointer(to: &destAddr) { ptr in
                    ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sa in
                        sendto(fd, probeData, probeData.count, 0, sa, socklen_t(MemoryLayout<sockaddr_in>.size))
                    }
                }

                guard sent > 0 else {
                    continuation.resume(returning: [])
                    return
                }

                // Receive responses until timeout
                var buffer = [UInt8](repeating: 0, count: 65535)
                let deadline = Date().addingTimeInterval(Double(timeoutSecs))

                while Date() < deadline {
                    var srcAddr = sockaddr_in()
                    var srcLen = socklen_t(MemoryLayout<sockaddr_in>.size)

                    let received = withUnsafeMutablePointer(to: &srcAddr) { ptr in
                        ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sa in
                            recvfrom(fd, &buffer, buffer.count, 0, sa, &srcLen)
                        }
                    }

                    if received > 0 {
                        let data = Data(buffer[0..<received])
                        if let xml = String(data: data, encoding: .utf8),
                           let device = Self.parseProbeMatch(xml: xml) {
                            devices[device.id] = device
                        }
                    } else {
                        // Timeout or error — stop receiving
                        break
                    }
                }

                continuation.resume(returning: Array(devices.values))
            }
        }
    }

    /// Parses a WS-Discovery ProbeMatch response XML into a DiscoveredDevice.
    static func parseProbeMatch(xml: String) -> DiscoveredDevice? {
        guard xml.contains("ProbeMatch") else { return nil }

        // Extract EndpointReference Address
        guard let id = extractElement(named: "Address", from: xml) else { return nil }

        // Extract XAddrs
        guard let xAddrsStr = extractElement(named: "XAddrs", from: xml) else { return nil }
        let xAddrs = xAddrsStr.split(separator: " ").compactMap { URL(string: String($0)) }
        guard !xAddrs.isEmpty else { return nil }

        // Extract Scopes
        let scopesStr = extractElement(named: "Scopes", from: xml) ?? ""
        let scopes = scopesStr.split(whereSeparator: { $0.isWhitespace }).map(String.init)

        // Parse name and hardware from scopes
        let name = scopes.first(where: { $0.contains("/name/") })
            .map { $0.components(separatedBy: "/name/").last ?? "" }
            .flatMap { $0.isEmpty ? nil : $0.removingPercentEncoding ?? $0 }

        let hardware = scopes.first(where: { $0.contains("/hardware/") })
            .map { $0.components(separatedBy: "/hardware/").last ?? "" }
            .flatMap { $0.isEmpty ? nil : $0.removingPercentEncoding ?? $0 }

        return DiscoveredDevice(
            id: id,
            name: name,
            xAddrs: xAddrs,
            hardware: hardware,
            scopes: scopes
        )
    }

    /// Simple XML element extractor handling namespace prefixes.
    private static func extractElement(named name: String, from xml: String) -> String? {
        let patterns = [
            "<\(name)>([^<]+)</\(name)>",
            "<[a-zA-Z]+:\(name)>([^<]+)</[a-zA-Z]+:\(name)>",
            "<\(name)[^>]*>([^<]+)</\(name)>",
            "<[a-zA-Z]+:\(name)[^>]*>([^<]+)</[a-zA-Z]+:\(name)>"
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators),
               let match = regex.firstMatch(in: xml, range: NSRange(xml.startIndex..., in: xml)),
               let valueRange = Range(match.range(at: 1), in: xml) {
                return String(xml[valueRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
}
