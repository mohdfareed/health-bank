import AppKit
import Foundation
import SwiftUI

struct AppLogo {
    static let logo = "heart.text.clipboard.fill"
}

let iconPath = URL(fileURLWithPath: "Icons/AppIcon.png")

let primary = Color(red: 255 / 255, green: 71 / 255, blue: 65 / 255)
let secondary = Color(red: 255 / 255, green: 94 / 255, blue: 163 / 255)
let iconPadding: CGFloat = 128

let gradient = LinearGradient(
    colors: [primary, secondary],
    startPoint: .top, endPoint: .bottom
)
