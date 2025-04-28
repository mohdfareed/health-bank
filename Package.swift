// swift-tools-version: 6.0

import Foundation
import PackageDescription

struct App {
    /// The name of the app package.
    static let name: String = "HealthBank"
}

let package = Package(
    name: App.name,
    platforms: [.iOS(.v18), .watchOS(.v11), .macOS(.v15)],
    products: [
        .executable(name: App.name, targets: [App.name])
    ],

    dependencies: [
        .package(
            url: "https://github.com/yonaskolb/XcodeGen.git", from: "2.43.0"
        )
    ],

    targets: [
        .executableTarget(
            name: App.name,
            path: "App",
            resources: [.process("Assets")],
        ),

        .testTarget(
            name: "\(App.name)Tests",
            dependencies: [Target.Dependency(stringLiteral: App.name)],
            path: "Tests/AppTests"
        ),
    ]
)
