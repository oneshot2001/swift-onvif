import Foundation

/// 2D vector for pan/tilt coordinates.
public struct Vector2D: Sendable {
    public let x: Float
    public let y: Float

    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
}

/// 1D vector for zoom.
public struct Vector1D: Sendable {
    public let x: Float

    public init(x: Float) {
        self.x = x
    }
}

/// PTZ speed (pan/tilt velocity + zoom velocity).
public struct PTZSpeed: Sendable {
    public let panTilt: Vector2D?
    public let zoom: Vector1D?

    public init(panTilt: Vector2D? = nil, zoom: Vector1D? = nil) {
        self.panTilt = panTilt
        self.zoom = zoom
    }
}

/// PTZ position (absolute coordinates).
public struct PTZPosition: Sendable {
    public let panTilt: Vector2D?
    public let zoom: Vector1D?

    public init(panTilt: Vector2D? = nil, zoom: Vector1D? = nil) {
        self.panTilt = panTilt
        self.zoom = zoom
    }
}

/// A saved PTZ preset.
public struct PTZPreset: Sendable {
    public let token: String
    public let name: String?
    public let position: PTZPosition?

    public init(token: String, name: String? = nil, position: PTZPosition? = nil) {
        self.token = token
        self.name = name
        self.position = position
    }
}

/// PTZ status including current position and movement state.
public struct PTZStatus: Sendable {
    public let position: PTZPosition?
    public let moveStatus: MoveStatus?

    public init(position: PTZPosition? = nil, moveStatus: MoveStatus? = nil) {
        self.position = position
        self.moveStatus = moveStatus
    }
}

/// Whether the camera is currently moving.
public struct MoveStatus: Sendable {
    public let panTilt: PTZMoveState
    public let zoom: PTZMoveState

    public init(panTilt: PTZMoveState = .idle, zoom: PTZMoveState = .idle) {
        self.panTilt = panTilt
        self.zoom = zoom
    }
}

/// PTZ movement state.
public enum PTZMoveState: String, Sendable {
    case idle = "IDLE"
    case moving = "MOVING"
    case unknown = "UNKNOWN"
}
