import Foundation
import Network

/// Discovers ONVIF-compliant cameras on the local network using WS-Discovery (SOAP-over-UDP multicast).
///
/// WS-Discovery sends a `Probe` message to the multicast address `239.255.255.250:3702`.
/// Cameras respond with `ProbeMatch` messages containing their ONVIF service endpoints.
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
            var devices: [String: DiscoveredDevice] = [:]
            let lock = NSLock()

            // Create UDP connection to multicast group
            let host = NWEndpoint.Host(Self.multicastAddress)
            let port = NWEndpoint.Port(rawValue: Self.multicastPort)!
            let params = NWParameters.udp
            params.allowLocalEndpointReuse = true

            let connection = NWConnection(host: host, port: port, using: params)

            // Set up a listener to receive responses on the same port
            let listenerParams = NWParameters.udp
            listenerParams.allowLocalEndpointReuse = true

            var hasResumed = false
            let resumeLock = NSLock()

            @Sendable func safeResume(_ result: Result<[DiscoveredDevice], Error>) {
                resumeLock.lock()
                defer { resumeLock.unlock() }
                guard !hasResumed else { return }
                hasResumed = true
                continuation.resume(with: result)
            }

            // Create a UDP listener on an ephemeral port
            guard let listener = try? NWListener(using: listenerParams, on: .any) else {
                continuation.resume(returning: [])
                return
            }

            listener.newConnectionHandler = { newConnection in
                newConnection.start(queue: .global())
                newConnection.receiveMessage { data, _, _, error in
                    if let data = data, let xml = String(data: data, encoding: .utf8) {
                        if let device = Self.parseProbeMatch(xml: xml) {
                            lock.lock()
                            devices[device.id] = device
                            lock.unlock()
                        }
                    }
                    // Keep receiving
                    newConnection.cancel()
                }
            }

            listener.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    // Listener is ready, send probe
                    connection.start(queue: .global())
                    connection.stateUpdateHandler = { connState in
                        if case .ready = connState {
                            let probeData = Data(probeMessage.utf8)
                            connection.send(content: probeData, completion: .contentProcessed { _ in })
                        }
                    }
                case .failed:
                    safeResume(.success([]))
                default:
                    break
                }
            }

            listener.start(queue: .global())

            // Timeout: collect responses and return
            let timeoutNanos = UInt64(timeout.components.seconds) * 1_000_000_000
                + UInt64(timeout.components.attoseconds / 1_000_000_000)
            DispatchQueue.global().asyncAfter(deadline: .now() + .nanoseconds(Int(timeoutNanos))) {
                connection.cancel()
                listener.cancel()
                lock.lock()
                let result = Array(devices.values)
                lock.unlock()
                safeResume(.success(result))
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
