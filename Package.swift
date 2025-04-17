// swift-tools-version: 6.0

import Foundation
import PackageDescription

struct App {
    static let name: String = "HealthTracker"
    static var file: URL { .init(filePath: self.name) }
    static var tests: URL { .init(filePath: "\(self.name)Tests") }
}

let package = Package(
    name: App.name,
    platforms: [
        .iOS(.v18), .watchOS(.v11),
        .macOS(.v15),  // for development only
    ],
    targets: [
        .target(
            name: "\(App.name)App", path: App.file.path(),
            exclude: [
                "Assets.xcassets",
                "HealthTracker.entitlements",
                "Info.plist",
            ]
        ),
        .testTarget(name: "\(App.name)AppTests", path: App.tests.path()),
    ]
)
