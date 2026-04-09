import SwiftONVIF
import Foundation

/// ONVIFExplorer — Simple CLI tool that discovers ONVIF cameras and queries their info.
///
/// Usage:
///   swift run ONVIFExplorer                          # Discover cameras on LAN
///   swift run ONVIFExplorer 192.168.1.100 admin pass # Query a specific camera

@main
struct ONVIFExplorer {
    static func main() async throws {
        let args = CommandLine.arguments

        if args.count >= 4 {
            // Direct connection mode: host, username, password
            let host = args[1]
            let username = args[2]
            let password = args[3]

            print("Connecting to \(host)...")
            let camera = ONVIFCamera(
                host: host,
                credential: ONVIFCredential(username: username, password: password)
            )

            // Get device info
            let info = try await camera.device.getDeviceInformation()
            print("  Manufacturer: \(info.manufacturer)")
            print("  Model: \(info.model)")
            print("  Firmware: \(info.firmwareVersion)")
            print("  Serial: \(info.serialNumber)")

            // Initialize services
            try await camera.initialize()

            // Get media profiles
            let profiles = try await camera.media.getProfiles()
            print("\n  Media Profiles (\(profiles.count)):")
            for profile in profiles {
                print("    [\(profile.token)] \(profile.name)")
                let streamURI = try await camera.media.getStreamURI(profileToken: profile.token)
                print("      Stream: \(streamURI.uri)")
            }

            // Check PTZ
            if let ptz = camera.ptz {
                let presets = try await ptz.getPresets(profileToken: profiles[0].token)
                print("\n  PTZ Presets (\(presets.count)):")
                for preset in presets {
                    print("    [\(preset.token)] \(preset.name ?? "unnamed")")
                }
            } else {
                print("\n  PTZ: Not supported")
            }

        } else {
            // Discovery mode
            print("Discovering ONVIF cameras on the network...")
            let discovery = ONVIFDiscovery()
            let devices = try await discovery.probe(timeout: .seconds(5))

            if devices.isEmpty {
                print("No cameras found.")
            } else {
                print("Found \(devices.count) camera(s):\n")
                for device in devices {
                    print("  \(device.name ?? "Unknown") (\(device.hardware ?? "unknown hw"))")
                    for addr in device.xAddrs {
                        print("    Endpoint: \(addr)")
                    }
                    print()
                }
            }
        }
    }
}
