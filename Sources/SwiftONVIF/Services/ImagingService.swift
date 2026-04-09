import Foundation

/// ONVIF Imaging Service (ver20/imaging/wsdl).
///
/// Controls image settings like brightness, contrast, exposure, focus, and white balance.
/// Not all cameras expose this service — check capabilities first.
///
/// Reference: ONVIF Imaging Service Specification.
public final class ImagingService: Sendable {

    private let client: SOAPClient
    private let serviceURL: URL

    init(client: SOAPClient, serviceURL: URL) {
        self.client = client
        self.serviceURL = serviceURL
    }

    /// Retrieves the current imaging settings for a video source.
    ///
    /// ONVIF operation: `GetImagingSettings`
    public func getImagingSettings(videoSourceToken: String) async throws -> ImagingSettings {
        // TODO: v0.4.0 — Implement GetImagingSettings SOAP call
        fatalError("Not yet implemented")
    }

    /// Updates imaging settings for a video source.
    ///
    /// ONVIF operation: `SetImagingSettings`
    public func setImagingSettings(videoSourceToken: String, settings: ImagingSettings) async throws {
        // TODO: v0.4.0 — Implement SetImagingSettings SOAP call
        fatalError("Not yet implemented")
    }

    /// Retrieves the valid ranges for imaging settings.
    ///
    /// ONVIF operation: `GetOptions`
    public func getOptions(videoSourceToken: String) async throws -> ImagingOptions {
        // TODO: v0.4.0
        fatalError("Not yet implemented")
    }
}

/// Camera imaging settings (brightness, contrast, etc.).
public struct ImagingSettings: Sendable {
    public var brightness: Float?
    public var contrast: Float?
    public var colorSaturation: Float?
    public var sharpness: Float?

    public init(brightness: Float? = nil, contrast: Float? = nil, colorSaturation: Float? = nil, sharpness: Float? = nil) {
        self.brightness = brightness
        self.contrast = contrast
        self.colorSaturation = colorSaturation
        self.sharpness = sharpness
    }
}

/// Valid ranges for imaging settings.
public struct ImagingOptions: Sendable {
    public let brightnessRange: ClosedRange<Float>?
    public let contrastRange: ClosedRange<Float>?
    public let colorSaturationRange: ClosedRange<Float>?
    public let sharpnessRange: ClosedRange<Float>?

    public init(
        brightnessRange: ClosedRange<Float>? = nil,
        contrastRange: ClosedRange<Float>? = nil,
        colorSaturationRange: ClosedRange<Float>? = nil,
        sharpnessRange: ClosedRange<Float>? = nil
    ) {
        self.brightnessRange = brightnessRange
        self.contrastRange = contrastRange
        self.colorSaturationRange = colorSaturationRange
        self.sharpnessRange = sharpnessRange
    }
}
