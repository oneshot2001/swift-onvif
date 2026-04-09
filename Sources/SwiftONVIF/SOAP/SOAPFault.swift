import Foundation

/// Represents a SOAP Fault returned by an ONVIF device.
///
/// When a device cannot process a request, it returns a SOAP Fault instead of the expected response.
/// Common faults include authentication failures, invalid arguments, and unsupported operations.
public struct SOAPFault: Error, Sendable {
    /// The fault code (e.g. "soap:Sender", "soap:Receiver").
    public let code: String

    /// The fault subcode if present (e.g. "ter:NotAuthorized", "ter:InvalidArgVal").
    public let subcode: String?

    /// Human-readable fault reason.
    public let reason: String

    /// Raw fault detail XML, if present.
    public let detail: String?

    public init(code: String, subcode: String?, reason: String, detail: String?) {
        self.code = code
        self.subcode = subcode
        self.reason = reason
        self.detail = detail
    }

    /// Attempts to parse a SOAP Fault from XML response data.
    ///
    /// - Parameter data: Raw XML response data.
    /// - Returns: A `SOAPFault` if the response contains a fault, otherwise `nil`.
    public static func parse(from data: Data) -> SOAPFault? {
        // TODO: v0.1.0 — Parse SOAP fault XML
        // Look for <soap:Fault> element, extract Code, Subcode, Reason, Detail
        return nil
    }
}
