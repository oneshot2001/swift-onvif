import Foundation

/// Device information returned by `GetDeviceInformation`.
public struct DeviceInfo: Sendable, Codable {
    public let manufacturer: String
    public let model: String
    public let firmwareVersion: String
    public let serialNumber: String
    public let hardwareId: String

    public init(manufacturer: String, model: String, firmwareVersion: String, serialNumber: String, hardwareId: String) {
        self.manufacturer = manufacturer
        self.model = model
        self.firmwareVersion = firmwareVersion
        self.serialNumber = serialNumber
        self.hardwareId = hardwareId
    }
}
