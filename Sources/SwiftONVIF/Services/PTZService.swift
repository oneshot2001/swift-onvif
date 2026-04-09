import Foundation

/// ONVIF PTZ Service (ver20/ptz/wsdl).
///
/// Controls pan, tilt, zoom operations on cameras that support PTZ.
/// Check `Capabilities.ptz` to verify PTZ support before using this service.
///
/// Reference: ONVIF PTZ Service Specification.
public final class PTZService: Sendable {

    private let client: SOAPClient
    private let serviceURL: URL

    init(client: SOAPClient, serviceURL: URL) {
        self.client = client
        self.serviceURL = serviceURL
    }

    /// Moves the camera continuously in the specified direction.
    ///
    /// The camera continues moving until `stop()` is called.
    ///
    /// ONVIF operation: `ContinuousMove`
    ///
    /// - Parameters:
    ///   - profileToken: The media profile token.
    ///   - velocity: Pan/tilt/zoom speed. Values range from -1.0 to 1.0.
    public func continuousMove(profileToken: String, velocity: PTZSpeed) async throws {
        // TODO: v0.3.0 — Implement ContinuousMove SOAP call
        fatalError("Not yet implemented")
    }

    /// Stops all PTZ movement.
    ///
    /// ONVIF operation: `Stop`
    ///
    /// - Parameters:
    ///   - profileToken: The media profile token.
    ///   - panTilt: Whether to stop pan/tilt movement. Default true.
    ///   - zoom: Whether to stop zoom movement. Default true.
    public func stop(profileToken: String, panTilt: Bool = true, zoom: Bool = true) async throws {
        // TODO: v0.3.0 — Implement Stop SOAP call
        fatalError("Not yet implemented")
    }

    /// Moves the camera to an absolute position.
    ///
    /// ONVIF operation: `AbsoluteMove`
    public func absoluteMove(profileToken: String, position: PTZPosition, speed: PTZSpeed? = nil) async throws {
        // TODO: v0.3.0
        fatalError("Not yet implemented")
    }

    /// Moves the camera relative to its current position.
    ///
    /// ONVIF operation: `RelativeMove`
    public func relativeMove(profileToken: String, translation: PTZPosition, speed: PTZSpeed? = nil) async throws {
        // TODO: v0.3.0
        fatalError("Not yet implemented")
    }

    /// Retrieves all configured PTZ presets.
    ///
    /// ONVIF operation: `GetPresets`
    public func getPresets(profileToken: String) async throws -> [PTZPreset] {
        // TODO: v0.3.0 — Implement GetPresets SOAP call
        fatalError("Not yet implemented")
    }

    /// Moves the camera to a saved preset position.
    ///
    /// ONVIF operation: `GotoPreset`
    public func gotoPreset(profileToken: String, presetToken: String, speed: PTZSpeed? = nil) async throws {
        // TODO: v0.3.0 — Implement GotoPreset SOAP call
        fatalError("Not yet implemented")
    }

    /// Saves the current camera position as a preset.
    ///
    /// ONVIF operation: `SetPreset`
    public func setPreset(profileToken: String, presetName: String?, presetToken: String? = nil) async throws -> String {
        // TODO: v0.3.0
        fatalError("Not yet implemented")
    }

    /// Retrieves the current PTZ status (position and move status).
    ///
    /// ONVIF operation: `GetStatus`
    public func getStatus(profileToken: String) async throws -> PTZStatus {
        // TODO: v0.3.0
        fatalError("Not yet implemented")
    }
}
