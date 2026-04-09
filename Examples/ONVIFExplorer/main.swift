import SwiftONVIF
import Foundation

/// ONVIFExplorer -- Simple CLI tool that discovers ONVIF cameras and queries their info.
///
/// Usage:
///   swift run ONVIFExplorer                          # Discover cameras on LAN
///   swift run ONVIFExplorer 192.168.1.100 root pass  # Query a specific camera

func run() async {
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

        do {
            // Get device info
            let info = try await camera.device.getDeviceInformation()
            print("  Manufacturer: \(info.manufacturer)")
            print("  Model:        \(info.model)")
            print("  Firmware:     \(info.firmwareVersion)")
            print("  Serial:       \(info.serialNumber)")
            print("  Hardware ID:  \(info.hardwareId)")

            // Get system date/time
            let dateTime = try await camera.device.getSystemDateAndTime()
            if let utc = dateTime.utcDateTime {
                let formatter = ISO8601DateFormatter()
                print("  Device Time:  \(formatter.string(from: utc)) (\(dateTime.dateTimeType))")
            }

            // Initialize services (discover capabilities)
            print("\nDiscovering services...")
            try await camera.initialize()

            if let caps = camera.capabilities {
                print("  Device:    \(caps.device?.xAddr.absoluteString ?? "N/A")")
                print("  Media:     \(caps.media?.xAddr.absoluteString ?? "N/A")")
                print("  PTZ:       \(caps.ptz?.xAddr.absoluteString ?? "Not supported")")
                print("  Imaging:   \(caps.imaging?.xAddr.absoluteString ?? "Not supported")")
                print("  Events:    \(caps.events?.xAddr.absoluteString ?? "Not supported")")
                print("  Analytics: \(caps.analytics?.xAddr.absoluteString ?? "Not supported")")
            }

        } catch let fault as SOAPFault {
            print("  SOAP Fault: \(fault)")
        } catch let err as ONVIFError {
            print("  ONVIF Error: \(err)")
        } catch {
            print("  Error: \(type(of: error)) - \(error)")
        }

    } else if args.count == 2 && args[1] == "--help" {
        print("ONVIFExplorer -- Discover and query ONVIF cameras")
        print("")
        print("Usage:")
        print("  swift run ONVIFExplorer                        Discover cameras on LAN")
        print("  swift run ONVIFExplorer <host> <user> <pass>   Query a specific camera")
        print("")

    } else {
        // Discovery mode
        print("Discovering ONVIF cameras on the network...")
        print("(waiting 5 seconds for responses)\n")

        do {
            let discovery = ONVIFDiscovery()
            let devices = try await discovery.probe(timeout: .seconds(5))

            if devices.isEmpty {
                print("No cameras found.")
                print("Make sure you're on the same subnet as your cameras.")
            } else {
                print("Found \(devices.count) camera(s):\n")
                for device in devices {
                    let name = device.name ?? "Unknown"
                    let hw = device.hardware ?? "unknown"
                    print("  \(name) (\(hw))")
                    for addr in device.xAddrs {
                        print("    Endpoint: \(addr)")
                    }
                    print()
                }
                print("To query a camera: swift run ONVIFExplorer <ip> <username> <password>")
            }
        } catch {
            print("Discovery error: \(error)")
        }
    }
}

// Entry point
let semaphore = DispatchSemaphore(value: 0)
Task {
    await run()
    semaphore.signal()
}
semaphore.wait()
