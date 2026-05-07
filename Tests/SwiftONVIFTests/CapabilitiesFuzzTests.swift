import XCTest
@testable import SwiftONVIF

/// Fuzz harness for ONVIF response parsers.
///
/// Drives a small set of mutators against real seed fixtures, and dumps
/// any failures to `tests/fuzz/failures/` for the /loop driver to pick up.
///
/// Convergence gate (any of these triggers a failure):
///   F1 — Crash (any throw escapes the parser without being caught explicitly)
///   F2 — Silent fail-open: destructive mutation parses to all-empty/all-nil result
///   F3 — False reject: benign mutation produces empty/nil where seed produced data
///
/// First-iteration target: `parseCapabilities`, which hard-codes `tt:` namespace —
/// NamespaceSwap should produce an all-nil Capabilities (F2).
final class CapabilitiesFuzzTests: XCTestCase {

    enum MutatorCategory {
        case destructive  // breaks XML or removes required content; parser should reject or error
        case benign       // tweaks shape but preserves semantic content; parser should still extract
    }

    struct Mutator {
        let name: String
        let category: MutatorCategory
        let apply: (String) -> String
    }

    static let mutators: [Mutator] = [
        Mutator(name: "NamespaceSwapTtToAlt", category: .benign) { input in
            input.replacingOccurrences(of: "tt:", with: "alt:")
        },
        Mutator(name: "TruncateAt60", category: .destructive) { input in
            let cutoff = (input.count * 60) / 100
            return String(input.prefix(cutoff))
        },
        Mutator(name: "DuplicateXAddr", category: .benign) { input in
            input.replacingOccurrences(
                of: "<tt:XAddr>http://192.168.1.32/onvif/device_service</tt:XAddr>",
                with: "<tt:XAddr>http://192.168.1.32/onvif/device_service</tt:XAddr><tt:XAddr>http://192.168.1.32/onvif/device_service</tt:XAddr>"
            )
        },
        // Wrong response wrapper — parser must verify it got GetCapabilitiesResponse, not
        // some other response type, before extracting service blocks.
        Mutator(name: "TypeConfuseResponseWrapper", category: .destructive) { input in
            input.replacingOccurrences(of: "GetCapabilitiesResponse", with: "GetServicesResponse")
        },
        Mutator(name: "EncodingMutation", category: .benign) { input in
            input.replacingOccurrences(of: #"encoding="UTF-8""#, with: #"encoding="ISO-8859-1""#)
        },
        Mutator(name: "LengthExtension", category: .benign) { input in
            input + "<junk>extra trailing content after envelope</junk>"
        },
    ]

    static let projectRoot: URL = {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // SwiftONVIFTests/
            .deletingLastPathComponent()  // Tests/
            .deletingLastPathComponent()  // <project root>
    }()

    static let failureDir: URL = {
        projectRoot.appendingPathComponent("tests/fuzz/failures", isDirectory: true)
    }()

    override func setUp() {
        super.setUp()
        try? FileManager.default.createDirectory(
            at: Self.failureDir,
            withIntermediateDirectories: true
        )
    }

    func testFuzzParseCapabilities() throws {
        let fixtureURL = Bundle.module.url(
            forResource: "get-capabilities-response",
            withExtension: "xml",
            subdirectory: "Fixtures"
        )!
        let seed = try String(contentsOf: fixtureURL, encoding: .utf8)

        // Baseline: parser produces non-empty Capabilities on the unmodified seed.
        let baseline = try DeviceService.parseCapabilities(from: seed)
        XCTAssertNotNil(baseline.device, "Baseline seed must yield a Device capability")
        XCTAssertNotNil(baseline.media, "Baseline seed must yield a Media capability")

        var failures: [(mutator: Mutator, mode: String, detail: String)] = []

        for mutator in Self.mutators {
            let mutated = mutator.apply(seed)

            let result: Capabilities
            do {
                result = try DeviceService.parseCapabilities(from: mutated)
            } catch {
                // Parser threw. For destructive mutators this is fine; for benign mutators it's F3.
                if mutator.category == .benign {
                    failures.append((mutator, "F3-FalseReject", "Threw on benign mutation: \(error)"))
                }
                continue
            }

            let allNil = (result.device == nil && result.media == nil && result.ptz == nil
                && result.imaging == nil && result.events == nil && result.analytics == nil)

            switch mutator.category {
            case .destructive:
                // Destructive mutation must be rejected outright — any non-throw result
                // (empty or partial) is silent fail-open.
                failures.append((
                    mutator,
                    "F2-SilentFailOpen",
                    "Destructive mutation parsed without throwing"
                ))
            case .benign:
                // Benign mutation should preserve the data we had at baseline.
                if allNil {
                    failures.append((
                        mutator,
                        "F2-SilentFailOpen",
                        "Benign mutation lost all data (likely hard-coded namespace assumption)"
                    ))
                } else if result.device == nil && baseline.device != nil {
                    failures.append((
                        mutator,
                        "F3-FalseReject",
                        "Benign mutation lost Device capability that baseline had"
                    ))
                }
            }
        }

        try writeFailures(failures, parser: "parseCapabilities", seed: seed)

        XCTAssertEqual(
            failures.count,
            0,
            "Fuzz failures: " + failures.map { "\($0.mutator.name)/\($0.mode)" }.joined(separator: ", ")
        )
    }

    private func writeFailures(
        _ failures: [(mutator: Mutator, mode: String, detail: String)],
        parser: String,
        seed: String
    ) throws {
        guard !failures.isEmpty else { return }
        let timestamp = Self.fuzzTimestamp()
        for f in failures {
            let dir = Self.failureDir.appendingPathComponent(
                "\(timestamp)-\(parser)-\(f.mutator.name)-\(f.mode)",
                isDirectory: true
            )
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let mutated = f.mutator.apply(seed)
            try mutated.write(
                to: dir.appendingPathComponent("input.xml"),
                atomically: true,
                encoding: .utf8
            )
            let report = """
                parser: \(parser)
                mutator: \(f.mutator.name)
                category: \(f.mutator.category)
                failure_mode: \(f.mode)
                detail: \(f.detail)
                """
            try report.write(
                to: dir.appendingPathComponent("report.txt"),
                atomically: true,
                encoding: .utf8
            )
        }
    }

    private static func fuzzTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: Date())
    }
}
