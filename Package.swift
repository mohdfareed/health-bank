// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "HealthTracker",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .watchOS(.v10),
    ],
    targets: [
        .target(
            name: "HealthTracker",
            path: "HealthTracker"
        )
    ]
)
