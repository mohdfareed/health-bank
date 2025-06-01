import SwiftUI

// MARK: Colors
// ============================================================================

extension Color {
    static var accent: Color { .init("Accent") }
    static var logoPrimary: Color { .init("LogoPrimary") }
    static var logoSecondary: Color { .init("LogoSecondary") }

    // Records
    static var calories: Color { .orange }
    static var dietaryCalorie: Color { .blue }
    static var activeCalorie: Color { .green }
    static var restingCalorie: Color { .indigo }
    static var duration: Color { .teal }
    static var weight: Color { .brown }

    // Macros
    static var macros: Color { .indigo }
    static var protein: Color { .purple }
    static var carbs: Color { .green }
    static var fat: Color { .yellow }

    // Data Sources
    static var local: Color { .primary }
    static var healthKit: Color { .pink }
    static var cloud: Color { .blue }
}

// MARK: Iconography
// ============================================================================

extension Image {
    static var logo: Image { .init("Logo") }
    static var logoAlt: Image { .init("LogoAlt") }

    // Records
    static var calories: Image { .init(systemName: "flame") }
    static var dietaryCalorie: Image { .init(systemName: "fork.knife") }
    static var activeCalorie: Image { .init(systemName: "figure.run") }
    static var restingCalorie: Image { .init(systemName: "zzz") }
    static var duration: Image { .init(systemName: "timer") }
    static var weight: Image { .init(systemName: "figure") }

    // Macros
    static var macros: Image { .init(systemName: "chart.pie") }
    static var protein: Image { .init(systemName: "dumbbell") }
    static var fat: Image { .init(systemName: "drop.circle") }
    static var carbs: Image { .init(systemName: "carrot.fill") }

    // Data Sources
    static var local: Image? { nil }
    static var cloud: Image { .init(systemName: "icloud.fill") }
    static var healthKit: Image { .init(systemName: "heart.fill") }
}

// MARK: Miscellaneous
// ============================================================================

extension Image {
    var asText: Text {
        Text("\(self)")
            .font(.footnote.bold())
    }
}

extension DataSource {
    var icon: Image? {
        switch self {
        case .local:
            return .local
        case .healthKit:
            return .healthKit
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

extension ShapeStyle where Self == Color {
    public static var logoGradient: LinearGradient {
        LinearGradient(
            colors: [.logoPrimary, .logoSecondary],
            startPoint: .bottom, endPoint: .top
        )
    }
}
