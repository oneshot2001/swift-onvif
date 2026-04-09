import Foundation

/// Represents a SOAP Fault returned by an ONVIF device.
public struct SOAPFault: Error, Sendable, CustomStringConvertible {
    /// The fault code (e.g. "soap:Sender", "soap:Receiver").
    public let code: String

    /// The fault subcode if present (e.g. "ter:NotAuthorized", "ter:InvalidArgVal").
    public let subcode: String?

    /// Human-readable fault reason.
    public let reason: String

    /// Raw fault detail XML, if present.
    public let detail: String?

    public var description: String {
        var desc = "SOAPFault(\(code)"
        if let subcode = subcode { desc += "/\(subcode)" }
        desc += "): \(reason)"
        return desc
    }

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
        guard let xml = String(data: data, encoding: .utf8) else { return nil }

        // Check if this is a fault response
        guard xml.contains("Fault") else { return nil }

        let code = extractElement(named: "Code", from: xml)
            .flatMap { extractElement(named: "Value", from: $0) } ?? "Unknown"
        let subcode = extractElement(named: "Subcode", from: xml)
            .flatMap { extractElement(named: "Value", from: $0) }
        let reason = extractElement(named: "Reason", from: xml)
            .flatMap { extractElement(named: "Text", from: $0) } ?? "Unknown fault"
        let detail = extractElement(named: "Detail", from: xml)

        return SOAPFault(code: code, subcode: subcode, reason: reason, detail: detail)
    }

    /// Simple XML element content extractor. Handles namespace-prefixed elements.
    private static func extractElement(named name: String, from xml: String) -> String? {
        // Match both <Name> and <prefix:Name>
        let patterns = [
            "<\(name)[ >]",       // <Name> or <Name attr>
            "<[a-zA-Z]+:\(name)[ >]"  // <soap:Name> etc.
        ]

        for pattern in patterns {
            guard let startRange = xml.range(of: pattern, options: .regularExpression) else { continue }

            // Find the content start (after the closing >)
            guard let tagClose = xml[startRange.upperBound...].range(of: ">")?.upperBound
                    ?? (xml[startRange.lowerBound...].contains(">") ? startRange.upperBound : nil) else { continue }

            let contentStart = xml[startRange.lowerBound...].contains(">")
                ? xml.range(of: ">", range: startRange.lowerBound..<xml.endIndex)!.upperBound
                : startRange.upperBound

            // Find the closing tag </Name> or </prefix:Name>
            let closingPatterns = ["</\(name)>", "</[a-zA-Z]+:\(name)>"]
            for closingPattern in closingPatterns {
                if let endRange = xml.range(of: closingPattern, options: .regularExpression, range: contentStart..<xml.endIndex) {
                    return String(xml[contentStart..<endRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        return nil
    }
}
