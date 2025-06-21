// swift-tools-version: 6.2

import Foundation
import PackageDescription

struct App {
    static let name: String = "HealthVaults"
}

let package = Package(
    name: App.name,
    platforms: [.iOS(.v26), .watchOS(.v26), .macOS(.v26)],

    targets: [
        .executableTarget(
            name: App.name,
            path: "App",
        ),
        .target(
            name: "\(App.name)Widgets",
            path: "Widgets",
        ),
    ]
)
