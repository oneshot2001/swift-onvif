import Foundation

/// ONVIF Event Service (ver10/events/wsdl).
///
/// Provides access to camera events via PullPoint subscription.
/// Events include motion detection, analytics triggers, I/O changes, and system events.
///
/// The PullPoint pattern:
/// 1. Create a subscription via `createPullPointSubscription()`
/// 2. Poll for events via `pullMessages()` in a loop
/// 3. Renew the subscription before it expires
/// 4. Unsubscribe when done
///
/// Reference: ONVIF Event Handling Specification.
public final class EventService: Sendable {

    private let client: SOAPClient
    private let serviceURL: URL

    init(client: SOAPClient, serviceURL: URL) {
        self.client = client
        self.serviceURL = serviceURL
    }

    /// Creates a PullPoint subscription for receiving events.
    ///
    /// ONVIF operation: `CreatePullPointSubscription`
    ///
    /// - Parameter filter: Optional topic filter expression (e.g. "tns1:VideoAnalytics//*").
    /// - Returns: Subscription info including the PullPoint endpoint URL.
    public func createPullPointSubscription(filter: String? = nil) async throws -> PullPointSubscription {
        // TODO: v1.1.0 — Implement CreatePullPointSubscription
        fatalError("Not yet implemented")
    }

    /// Pulls pending events from an active subscription.
    ///
    /// ONVIF operation: `PullMessages`
    ///
    /// - Parameters:
    ///   - subscriptionURL: The PullPoint endpoint URL from the subscription.
    ///   - timeout: Maximum time to wait for events. Device may return earlier if events are available.
    ///   - messageLimit: Maximum number of events to return.
    /// - Returns: Array of notification messages.
    public func pullMessages(
        subscriptionURL: URL,
        timeout: Duration = .seconds(30),
        messageLimit: Int = 100
    ) async throws -> [NotificationMessage] {
        // TODO: v1.1.0 — Implement PullMessages
        fatalError("Not yet implemented")
    }

    /// Renews an active subscription before it expires.
    ///
    /// ONVIF operation: `Renew`
    public func renew(subscriptionURL: URL, terminationTime: Duration = .seconds(60)) async throws {
        // TODO: v1.1.0
        fatalError("Not yet implemented")
    }

    /// Unsubscribes from a PullPoint subscription.
    ///
    /// ONVIF operation: `Unsubscribe`
    public func unsubscribe(subscriptionURL: URL) async throws {
        // TODO: v1.1.0
        fatalError("Not yet implemented")
    }
}

/// Active PullPoint subscription.
public struct PullPointSubscription: Sendable {
    public let subscriptionURL: URL
    public let currentTime: Date
    public let terminationTime: Date

    public init(subscriptionURL: URL, currentTime: Date, terminationTime: Date) {
        self.subscriptionURL = subscriptionURL
        self.currentTime = currentTime
        self.terminationTime = terminationTime
    }
}

/// An event notification message from the device.
public struct NotificationMessage: Sendable {
    public let topic: String
    public let timestamp: Date
    public let source: [String: String]
    public let data: [String: String]

    public init(topic: String, timestamp: Date, source: [String: String], data: [String: String]) {
        self.topic = topic
        self.timestamp = timestamp
        self.source = source
        self.data = data
    }
}
