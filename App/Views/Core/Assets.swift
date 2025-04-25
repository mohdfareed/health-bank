import SwiftUI

// TODO: Generate using: https://github.com/RedMadRobot/figma-export

// MARK: Colors
// ============================================================================

extension ShapeStyle where Self == Color {
    public static var logoPrimary: Color {
        Color(red: 255 / 255, green: 71 / 255, blue: 65 / 255)
    }
    public static var logoSecondary: Color {
        Color(red: 255 / 255, green: 94 / 255, blue: 163 / 255)
    }

    public static var logoGradient: LinearGradient {
        LinearGradient(
            colors: [.logoPrimary, .logoSecondary],
            startPoint: .top, endPoint: .bottom
        )
    }
}

// MARK: Iconography
// ============================================================================

public struct AppSymbols {
    // static let logo = "heart.text.clipboard.fill"

    static let burnedCalorie = "flame"
    static let dietaryCalorie = "fork.knife"

    static let macros = "chart.pie"
    static let protein = "dumbbell"
    static let fat = "drop.circle"
    static let carbs = "carrot"

    static let weight = "figure"
    static let workout = "figure.run"
}

// MARK: App Logo
// ============================================================================

extension Image {
    static var appLogo: Image { return Image("Icons/Logo.svg") }
    static var appLogoFilled: Image { return Image("Icons/LogoFilled.svg") }
}

var AppLogo: some View {
    Image.appLogo
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(.logoGradient)
}

var AppLogoAlt: some View {
    Image.appLogoFilled
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(.logoGradient)
}
