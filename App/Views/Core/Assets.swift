import SwiftUI

// TODO: Generate using: https://github.com/RedMadRobot/figma-export

// MARK: Colors
// ============================================================================

extension ShapeStyle where Self == Color {
    public static var logoGradient: LinearGradient {
        LinearGradient(
            colors: [.logoPrimary, .logoSecondary],
            startPoint: .bottom, endPoint: .top
        )
    }
}

// MARK: Iconography
// ============================================================================

public struct AppSymbols {
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
    static var logo: Image { return Image("Logo") }
    static var logoAlt: Image { return Image("LogoAlt") }
}

var AppLogo: some View {
    Image.logo
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(.logoGradient)
}

var AppLogoAlt: some View {
    Image.logoAlt
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(.logoGradient)
}
