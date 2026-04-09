import Foundation
import XMLCoder

/// HTTP client for sending SOAP requests to ONVIF device service endpoints.
///
/// Handles:
/// - Encoding Codable request bodies to XML via XMLCoder
/// - Wrapping in SOAP envelopes with WS-Security
/// - Sending via URLSession
/// - Decoding XML responses back to Codable types via XMLCoder
///
/// XMLCoder patterns used here:
/// ```swift
/// // Encoding a request body struct to XML
/// let encoder = XMLEncoder()
/// let bodyXML = try encoder.encode(request, withRootKey: "tds:GetDeviceInformation")
///
/// // Decoding a response from XML data
/// let decoder = XMLDecoder()
/// decoder.shouldProcessNamespaces = true
/// let response = try decoder.decode(ResponseType.self, from: xmlData)
/// ```
public final class SOAPClient: Sendable {

    private let session: URLSession
    private let credential: ONVIFCredential?

    /// Creates a SOAP client.
    ///
    /// - Parameters:
    ///   - credential: Optional credentials for WS-Security authentication.
    ///   - session: URLSession to use. Defaults to `.shared`.
    public init(credential: ONVIFCredential? = nil, session: URLSession = .shared) {
        self.credential = credential
        self.session = session
    }

    /// Sends a SOAP request and decodes the response.
    ///
    /// - Parameters:
    ///   - url: The ONVIF service endpoint URL.
    ///   - action: The SOAP action URI (used in HTTP header and WS-Addressing).
    ///   - body: The SOAP body XML string.
    /// - Returns: Raw XML response data.
    public func send(to url: URL, action: String, body: String) async throws -> Data {
        // TODO: v0.1.0 — Implement SOAP HTTP POST
        // 1. Generate WS-Security token if credential is set
        // 2. Wrap body in SOAP envelope via SOAPEnvelope.wrap()
        // 3. Create URLRequest with Content-Type: application/soap+xml;charset=utf-8
        // 4. Set SOAPAction header
        // 5. POST and return response data
        // 6. Check for SOAPFault in response
        fatalError("Not yet implemented")
    }

    /// Sends a SOAP request and decodes the response body into a Codable type.
    ///
    /// - Parameters:
    ///   - url: The ONVIF service endpoint URL.
    ///   - action: The SOAP action URI.
    ///   - body: The SOAP body XML string.
    ///   - responseType: The Codable type to decode the SOAP response body into.
    /// - Returns: Decoded response object.
    public func sendAndDecode<T: Decodable>(
        to url: URL,
        action: String,
        body: String,
        as responseType: T.Type
    ) async throws -> T {
        // TODO: v0.1.0 — Implement with XMLDecoder
        // 1. Call send() to get raw XML data
        // 2. Extract SOAP body content from envelope
        // 3. Decode body XML into T using XMLDecoder
        fatalError("Not yet implemented")
    }
}
