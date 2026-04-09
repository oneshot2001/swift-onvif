import Foundation

/// Builds SOAP 1.2 XML envelopes for ONVIF service calls.
///
/// ONVIF uses SOAP over HTTP for all service operations. Each request is a SOAP envelope
/// containing a header (with optional WS-Security) and a body (the service operation).
public enum SOAPEnvelope {

    /// ONVIF SOAP namespace constants.
    public enum Namespace {
        public static let soap = "http://www.w3.org/2003/05/soap-envelope"
        public static let device = "http://www.onvif.org/ver10/device/wsdl"
        public static let media = "http://www.onvif.org/ver10/media/wsdl"
        public static let media2 = "http://www.onvif.org/ver20/media/wsdl"
        public static let ptz = "http://www.onvif.org/ver20/ptz/wsdl"
        public static let imaging = "http://www.onvif.org/ver20/imaging/wsdl"
        public static let event = "http://www.onvif.org/ver10/events/wsdl"
        public static let schema = "http://www.onvif.org/ver10/schema"
    }

    /// Wraps a SOAP body XML string in a complete SOAP envelope with optional WS-Security header.
    ///
    /// - Parameters:
    ///   - body: The XML content for the SOAP body (the service operation).
    ///   - security: Optional WS-Security UsernameToken for authentication.
    /// - Returns: Complete SOAP envelope XML string.
    public static func wrap(body: String, security: WSSecurity.UsernameToken? = nil) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <soap:Envelope \
        xmlns:soap="http://www.w3.org/2003/05/soap-envelope" \
        xmlns:tds="http://www.onvif.org/ver10/device/wsdl" \
        xmlns:trt="http://www.onvif.org/ver10/media/wsdl" \
        xmlns:tr2="http://www.onvif.org/ver20/media/wsdl" \
        xmlns:tptz="http://www.onvif.org/ver20/ptz/wsdl" \
        xmlns:timg="http://www.onvif.org/ver20/imaging/wsdl" \
        xmlns:tev="http://www.onvif.org/ver10/events/wsdl" \
        xmlns:tt="http://www.onvif.org/ver10/schema">
        """

        if let security = security {
            xml += "<soap:Header>\(security.xmlElement)</soap:Header>"
        }

        xml += "<soap:Body>\(body)</soap:Body>"
        xml += "</soap:Envelope>"

        return xml
    }
}
