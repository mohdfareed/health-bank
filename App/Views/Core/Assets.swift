import SwiftUI

// MARK: Colors
// ============================================================================

extension Color {
    static var logoPrimary: Color { Color("LogoPrimary") }
    static var logoSecondary: Color { Color("LogoSecondary") }

    static var accent: Color { Color("Accent") }
    static var healthKit: Color { Color.pink }
    static var local: Color { Color.primary }
    static var cloud: Color { Color.blue }
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
    // App Logo
    static var logo: Image { Image("Logo") }
    static var logoAlt: Image { Image("LogoAlt") }

    // Records
    static var calories: Image { Image(systemName: "flame") }
    static var dietaryCalorie: Image { Image(systemName: "fork.knife") }
    static var activeCalorie: Image { Image(systemName: "figure.run") }
    static var restingCalorie: Image { Image(systemName: "zzz") }
    static var duration: Image { Image(systemName: "timer") }
    static var weight: Image { Image(systemName: "figure") }

    // Macros
    static var macros: Image { Image(systemName: "chart.pie") }
    static var protein: Image { Image(systemName: "dumbbell") }
    static var fat: Image { Image(systemName: "drop.circle") }
    static var carbs: Image { Image(systemName: "carrot.fill") }

    // Data Sources
    static var sourceLocal: Image? { nil }
    static var sourceCloud: Image { Image(systemName: "icloud.fill") }
    static var sourceHealthKit: Image { Image(systemName: "heart.circle.fill") }

    // Actions
    static var computedIcon: Image { Image(systemName: "function") }
    static var editIcon: Image { Image(systemName: "pencil") }
    static var saveIcon: Image { Image(systemName: "checkmark.circle.fill") }
    static var cancelIcon: Image { Image(systemName: "xmark.circle.fill") }
    static var dateIcon: Image { Image(systemName: "calendar") }
    static var resetIcon: Image { Image(systemName: "arrow.clockwise") }
}

// MARK: Logos
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

var HealthKitLogo: some View {
    Image.sourceHealthKit
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(Color.healthKit)
}

// MARK: Data Sources
// ============================================================================

extension DataSource {
    var image: some View {
        switch self {
        case .local:
            return AnyView(AppLogo)
        case .healthKit:
            return AnyView(HealthKitLogo)
        }
    }

    var icon: Image? {
        switch self {
        case .local:
            return .sourceLocal
        case .healthKit:
            return .sourceHealthKit
        }
    }

    var color: Color {
        switch self {
        case .local:
            return .local
        case .healthKit:
            return .healthKit
        }
    }
}

// MARK: Styles
// ============================================================================

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.thinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
