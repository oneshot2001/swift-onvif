// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftONVIF",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "SwiftONVIF",
            targets: ["SwiftONVIF"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", from: "0.17.1")
    ],
    targets: [
        .target(
            name: "SwiftONVIF",
            dependencies: ["XMLCoder"]
        ),
        .testTarget(
            name: "SwiftONVIFTests",
            dependencies: ["SwiftONVIF"],
            resources: [.copy("Fixtures")]
        ),
        .executableTarget(
            name: "ONVIFExplorer",
            dependencies: ["SwiftONVIF"],
            path: "Examples/ONVIFExplorer"
        )
    ]
)
