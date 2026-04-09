# SwiftONVIF

A pure Swift ONVIF client library for iOS, macOS, and tvOS.

**The first async/await-native, SPM-compatible ONVIF library for Swift.**

SwiftONVIF provides a clean, type-safe API for discovering and controlling ONVIF-compliant IP cameras. No binary dependencies, no Objective-C bridging, no closed-source SOAP engines.

## Features

- **WS-Discovery** — Find cameras on the local network via multicast probe
- **WS-Security** — UsernameToken digest authentication (CryptoKit-based)
- **Device Service** — Device information, capabilities, service discovery
- **Media Service** — Profiles, RTSP stream URIs, snapshot URIs, encoder configurations
- **Media2 Service** — H.265 support and modern profile management
- **PTZ Service** — Pan, tilt, zoom control with presets
- **Imaging Service** — Brightness, contrast, exposure settings
- **Event Service** — PullPoint subscription for camera events *(planned)*
- **Pure Swift** — async/await, Sendable, Codable throughout
- **Zero binary dependencies** — only Foundation, Network, XMLCoder, CryptoKit

## Requirements

- Swift 5.9+
- macOS 13+ / iOS 16+ / tvOS 16+

## Installation

Add SwiftONVIF to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/oneshot2001/swift-onvif.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "SwiftONVIF", package: "swift-onvif")
    ]
)
```

## Quick Start

### Discover Cameras

```swift
import SwiftONVIF

let discovery = ONVIFDiscovery()
let devices = try await discovery.probe(timeout: .seconds(5))

for device in devices {
    print("\(device.name ?? "Unknown") at \(device.xAddrs)")
}
```

### Connect and Query

```swift
let camera = ONVIFCamera(
    host: "192.168.1.100",
    credential: ONVIFCredential(username: "admin", password: "pass")
)

// Device info
let info = try await camera.device.getDeviceInformation()
print("\(info.manufacturer) \(info.model) (fw: \(info.firmwareVersion))")

// Initialize services (discovers what the camera supports)
try await camera.initialize()

// Media profiles and stream URIs
let profiles = try await camera.media.getProfiles()
let streamURI = try await camera.media.getStreamURI(profileToken: profiles[0].token)
print("RTSP: \(streamURI.uri)")

// Snapshot
let snapshotURI = try await camera.media.getSnapshotURI(profileToken: profiles[0].token)
```

### PTZ Control

```swift
// Check if camera supports PTZ
if let ptz = camera.ptz {
    // Pan right
    try await ptz.continuousMove(
        profileToken: profiles[0].token,
        velocity: PTZSpeed(panTilt: Vector2D(x: 0.5, y: 0.0))
    )

    // Stop
    try await ptz.stop(profileToken: profiles[0].token)

    // Go to preset
    let presets = try await ptz.getPresets(profileToken: profiles[0].token)
    try await ptz.gotoPreset(
        profileToken: profiles[0].token,
        presetToken: presets[0].token
    )
}
```

### Imaging Settings

```swift
if let imaging = camera.imaging {
    var settings = try await imaging.getImagingSettings(videoSourceToken: "video_source_1")
    settings.brightness = 60.0
    try await imaging.setImagingSettings(videoSourceToken: "video_source_1", settings: settings)
}
```

## Example CLI

The repo includes `ONVIFExplorer`, a simple command-line tool:

```bash
# Discover cameras on the network
swift run ONVIFExplorer

# Query a specific camera
swift run ONVIFExplorer 192.168.1.100 admin password
```

## Supported ONVIF Operations

| Service | Operation | Version |
|---------|-----------|---------|
| Device | GetDeviceInformation | v0.1.0 |
| Device | GetCapabilities | v0.1.0 |
| Device | GetServices | v0.1.0 |
| Device | GetSystemDateAndTime | v0.1.0 |
| Media | GetProfiles | v0.2.0 |
| Media | GetStreamUri | v0.2.0 |
| Media | GetSnapshotUri | v0.2.0 |
| Media | GetVideoEncoderConfigurations | v0.2.0 |
| Media2 | GetProfiles (ver20) | v0.4.0 |
| Media2 | GetStreamUri (ver20) | v0.4.0 |
| PTZ | ContinuousMove | v0.3.0 |
| PTZ | Stop | v0.3.0 |
| PTZ | AbsoluteMove | v0.3.0 |
| PTZ | RelativeMove | v0.3.0 |
| PTZ | GetPresets / GotoPreset | v0.3.0 |
| PTZ | GetStatus | v0.3.0 |
| Imaging | GetImagingSettings | v0.4.0 |
| Imaging | SetImagingSettings | v0.4.0 |
| Event | PullPointSubscription | v1.1.0 |

## Architecture

```
SwiftONVIF/
├── Discovery/      # WS-Discovery multicast (Network.framework)
├── Auth/           # WS-Security UsernameToken (CryptoKit)
├── SOAP/           # SOAP envelope builder + HTTP client (XMLCoder)
├── Services/       # ONVIF service implementations
│   ├── DeviceService
│   ├── MediaService
│   ├── Media2Service
│   ├── PTZService
│   ├── ImagingService
│   └── EventService
├── Models/         # Codable data structures
└── ONVIFCamera     # High-level convenience API
```

## License

MIT License. See [LICENSE](LICENSE) for details.

## Author

Matthew Visher ([@oneshot2001](https://github.com/oneshot2001))
