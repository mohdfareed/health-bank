// swift-tools-version: 6.0

import Foundation
import PackageDescription

struct App {
    static let name: String = "HealthBank"
}

let package = Package(
    name: App.name,
    platforms: [.iOS(.v18), .watchOS(.v11), .macOS(.v15)],

    dependencies: [
        .package(
            url: "https://github.com/yonaskolb/XcodeGen.git", from: "2.43.0"
        )
    ],

    targets: [
        .executableTarget(
            name: App.name,
            path: "App",
        ),

        .testTarget(
            name: "\(App.name)Tests",
            dependencies: [Target.Dependency(stringLiteral: App.name)],
            path: "Tests/AppTests"
        ),
    ]
)
