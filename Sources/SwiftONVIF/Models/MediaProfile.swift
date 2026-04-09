import Foundation

/// An ONVIF media profile binding video source, encoder, and optional PTZ/analytics configs.
public struct MediaProfile: Sendable {
    /// Unique token identifying this profile.
    public let token: String

    /// Human-readable profile name.
    public let name: String

    /// Whether this profile is fixed (cannot be deleted).
    public let fixed: Bool

    /// Video source configuration token, if present.
    public let videoSourceToken: String?

    /// Video encoder configuration token, if present.
    public let videoEncoderToken: String?

    /// PTZ configuration token, if present (nil means no PTZ on this profile).
    public let ptzToken: String?

    public init(
        token: String,
        name: String,
        fixed: Bool = false,
        videoSourceToken: String? = nil,
        videoEncoderToken: String? = nil,
        ptzToken: String? = nil
    ) {
        self.token = token
        self.name = name
        self.fixed = fixed
        self.videoSourceToken = videoSourceToken
        self.videoEncoderToken = videoEncoderToken
        self.ptzToken = ptzToken
    }
}
