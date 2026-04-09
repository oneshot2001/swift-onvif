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

    public init() {}

    /// Sends a WS-Discovery Probe and collects responses until timeout.
    ///
    /// - Parameter timeout: How long to listen for responses. Default 5 seconds.
    /// - Returns: Array of discovered devices.
    public func probe(timeout: Duration = .seconds(5)) async throws -> [DiscoveredDevice] {
        // TODO: v0.1.0 — Implement WS-Discovery multicast via Network.framework
        // 1. Create NWConnection to UDP multicast 239.255.255.250:3702
        // 2. Send SOAP Probe envelope (WS-Discovery spec)
        // 3. Collect ProbeMatch responses until timeout
        // 4. Parse each ProbeMatch XML into DiscoveredDevice
        fatalError("Not yet implemented")
    }
}
