// swift-tools-version: 6.2

import Foundation
import PackageDescription

struct App {
    static let name: String = "HealthVaults"
}

let package = Package(
    name: App.name,
    platforms: [.iOS(.v26), .watchOS(.v26), .macOS(.v26)],

    dependencies: [
        .package(
            url: "https://github.com/yonaskolb/XcodeGen.git", from: "2.43.0"
        )
    ],

    targets: [
        .executableTarget(
            name: App.name,
            path: "App",
        )
    ]
)
