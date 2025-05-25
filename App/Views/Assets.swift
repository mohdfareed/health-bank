import SwiftUI

// MARK: Colors
// ============================================================================

extension Color {
    static var logoPrimary: Color { Color("LogoPrimary") }
    static var logoSecondary: Color { Color("LogoSecondary") }
    static var accent: Color { Color("Accent") }
}

extension ShapeStyle where Self == Color {
    public static var logoGradient: LinearGradient {
        LinearGradient(
            colors: [Color.logoPrimary, Color.logoSecondary],
            startPoint: .bottom, endPoint: .top
        )
    }
}

// MARK: Iconography
// ============================================================================

extension Image {
    static var logo: Image { Image("Logo") }
    static var logoAlt: Image { Image("LogoAlt") }

    static var burnedCalorie: Image { Image(systemName: "flame") }
    static var dietaryCalorie: Image { Image(systemName: "fork.knife") }

    static var macros: Image { Image(systemName: "chart.pie") }
    static var protein: Image { Image(systemName: "dumbbell") }
    static var fat: Image { Image(systemName: "drop.circle") }
    static var carbs: Image { Image(systemName: "carrot") }

    static var weight: Image { Image(systemName: "figure") }
    static var workout: Image { Image(systemName: "figure.run") }
}

// MARK: App Logo
// ============================================================================

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
