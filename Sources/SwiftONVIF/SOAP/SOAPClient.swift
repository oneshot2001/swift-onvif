import Foundation
import XMLCoder

/// HTTP client for sending SOAP requests to ONVIF device service endpoints.
///
/// Supports two authentication methods:
/// 1. **HTTP Digest** -- handled via URLSession credential delegate (most Axis cameras)
/// 2. **WS-Security UsernameToken** -- embedded in SOAP header (ONVIF standard)
///
/// The client tries WS-Security first. If the device returns HTTP 401,
/// it retries with HTTP Digest authentication.
public final class SOAPClient: @unchecked Sendable {

    private let credential: ONVIFCredential?
    private let digestSession: URLSession
    private let plainSession: URLSession
    private let authDelegate: DigestAuthDelegate?

    /// Creates a SOAP client.
    ///
    /// - Parameters:
    ///   - credential: Optional credentials for authentication.
    ///   - session: URLSession to use for non-authenticated requests. Defaults to `.shared`.
    public init(credential: ONVIFCredential? = nil, session: URLSession = .shared) {
        self.credential = credential
        self.plainSession = session

        if let credential = credential {
            // Create a session with HTTP Digest auth support
            let delegate = DigestAuthDelegate(credential: credential)
            self.authDelegate = delegate
            self.digestSession = URLSession(
                configuration: .default,
                delegate: delegate,
                delegateQueue: nil
            )
        } else {
            self.authDelegate = nil
            self.digestSession = session
        }
    }

    /// Sends a SOAP request and returns the raw XML response data.
    ///
    /// Uses dual authentication: WS-Security in the SOAP header (for cameras that support it)
    /// plus HTTP Digest via URLSession delegate (for cameras like Axis that require it).
    /// Both are included simultaneously so the request works regardless of which method
    /// the camera expects.
    ///
    /// - Parameters:
    ///   - url: The ONVIF service endpoint URL.
    ///   - action: The SOAP action URI.
    ///   - body: The SOAP body XML string (without envelope wrapper).
    /// - Returns: Raw XML response data (full SOAP envelope).
    public func send(to url: URL, action: String, body: String) async throws -> Data {
        // Use HTTP Digest auth (handled by URLSession delegate).
        // WS-Security is not included by default -- most cameras (Axis, Hanwha, etc.)
        // use HTTP Digest and reject WS-Security with HTTP 400.
        let envelope = SOAPEnvelope.wrap(body: body, security: nil)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(envelope.utf8)
        request.setValue(
            "application/soap+xml;charset=utf-8;action=\"\(action)\"",
            forHTTPHeaderField: "Content-Type"
        )
        request.timeoutInterval = 10

        // Use the digest session which handles HTTP 401 challenges automatically
        // Pass the delegate directly to ensure auth challenges are handled
        let (data, response): (Data, URLResponse)
        if let authDelegate = authDelegate {
            (data, response) = try await digestSession.data(for: request, delegate: authDelegate)
        } else {
            (data, response) = try await digestSession.data(for: request)
        }

        if let httpResponse = response as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            if data.count > 0, let fault = SOAPFault.parse(from: data) {
                throw fault
            }
            throw ONVIFError.httpError(statusCode: httpResponse.statusCode)
        }

        // Check for SOAP fault in 200 response (only if body looks like a fault)
        if data.count > 0 {
            if let xml = String(data: data, encoding: .utf8), xml.contains("Fault") {
                if let fault = SOAPFault.parse(from: data) {
                    throw fault
                }
            }
        }

        return data
    }

    /// Extracts the SOAP Body content from a full SOAP envelope response.
    ///
    /// - Parameter data: Full SOAP envelope XML data.
    /// - Returns: The XML string content inside the `<Body>` element.
    public static func extractBody(from data: Data) -> String? {
        guard let xml = String(data: data, encoding: .utf8) else { return nil }

        // Find any variant of the Body opening tag
        let bodyOpenPattern = "<[A-Za-z-]+:Body>"
        guard let regex = try? NSRegularExpression(pattern: bodyOpenPattern),
              let match = regex.firstMatch(in: xml, range: NSRange(xml.startIndex..., in: xml)),
              let matchRange = Range(match.range, in: xml) else {
            return nil
        }

        let contentStart = matchRange.upperBound

        // Find closing Body tag
        let closingPatterns = ["</SOAP-ENV:Body>", "</soap:Body>", "</s:Body>", "</env:Body>"]
        for closing in closingPatterns {
            if let bodyEnd = xml.range(of: closing, range: contentStart..<xml.endIndex) {
                return String(xml[contentStart..<bodyEnd.lowerBound])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
}

/// URLSession delegate that responds to HTTP Digest authentication challenges.
final class DigestAuthDelegate: NSObject, URLSessionTaskDelegate, Sendable {
    private let credential: ONVIFCredential

    init(credential: ONVIFCredential) {
        self.credential = credential
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest {
            let urlCredential = URLCredential(
                user: credential.username,
                password: credential.password,
                persistence: .forSession
            )
            completionHandler(.useCredential, urlCredential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

/// Errors specific to SwiftONVIF operations.
public enum ONVIFError: Error, CustomStringConvertible {
    case httpError(statusCode: Int)
    case invalidResponse
    case serviceNotAvailable(String)
    case parseError(String)
    case timeout

    public var description: String {
        switch self {
        case .httpError(let code): return "HTTP error: \(code)"
        case .invalidResponse: return "Invalid or unparseable response"
        case .serviceNotAvailable(let service): return "Service not available: \(service)"
        case .parseError(let detail): return "XML parse error: \(detail)"
        case .timeout: return "Request timed out"
        }
    }
}
