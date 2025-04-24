#!/usr/bin/env swift

import AppKit
import Foundation
import SwiftUI

let iconPath = URL(fileURLWithPath: "Assets/AppIcon.png")

let logo = "heart.text.clipboard.fill"
let primary = Color(red: 255 / 255, green: 71 / 255, blue: 65 / 255)
let secondary = Color(red: 255 / 255, green: 94 / 255, blue: 163 / 255)
let iconPadding: CGFloat = 128

let gradient = LinearGradient(
    colors: [primary, secondary],
    startPoint: .top, endPoint: .bottom
)

// MARK: Create image
// ============================================================================

guard
    let image = await Task { @MainActor in
        let logoImage = Image(systemName: logo)
            .resizable()
            .foregroundStyle(gradient)
            .background(Color.clear)
            .aspectRatio(contentMode: .fit)
            .padding(iconPadding)
            .frame(width: 1024, height: 1024)
        let renderer = ImageRenderer(content: logoImage)
        return renderer.nsImage?.tiffRepresentation
    }.value
else {
    print("Error rendering image")
    exit(1)
}

// MARK: Save image to file
// ============================================================================

guard
    let bitmap = NSBitmapImageRep(data: image),
    let data = bitmap.representation(using: .png, properties: [:])
else {
    print("Error converting image to PNG data")
    exit(1)
}

do {
    try data.write(to: iconPath)
} catch {
    print("Error writing image to file: \(error)")
    exit(1)
}
print("Image saved to \(iconPath.path)")
