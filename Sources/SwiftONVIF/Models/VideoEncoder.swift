import Foundation

/// Video encoder configuration.
public struct VideoEncoder: Sendable {
    public let token: String
    public let name: String
    public let encoding: VideoEncoding
    public let resolution: Resolution
    public let quality: Float
    public let rateControl: RateControl?

    public init(
        token: String,
        name: String,
        encoding: VideoEncoding,
        resolution: Resolution,
        quality: Float,
        rateControl: RateControl? = nil
    ) {
        self.token = token
        self.name = name
        self.encoding = encoding
        self.resolution = resolution
        self.quality = quality
        self.rateControl = rateControl
    }
}

/// Video encoding type.
public enum VideoEncoding: String, Sendable {
    case jpeg = "JPEG"
    case mpeg4 = "MPEG4"
    case h264 = "H264"
    case h265 = "H265"
}

/// Video resolution.
public struct Resolution: Sendable {
    public let width: Int
    public let height: Int

    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

/// Encoder rate control settings.
public struct RateControl: Sendable {
    public let frameRateLimit: Int
    public let encodingInterval: Int
    public let bitrateLimit: Int

    public init(frameRateLimit: Int, encodingInterval: Int, bitrateLimit: Int) {
        self.frameRateLimit = frameRateLimit
        self.encodingInterval = encodingInterval
        self.bitrateLimit = bitrateLimit
    }
}
