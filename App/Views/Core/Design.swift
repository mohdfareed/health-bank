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

    // Actions
    static var computedIcon: Color { Color.indigo }
    static var editIcon: Color { .blue }
    static var saveIcon: Color { .green }
    static var cancelIcon: Color { .red }
    static var dateIcon: Color { .gray }
    static var resetIcon: Color { .blue }
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
    static var healthKit: Image { .init(systemName: "heart.circle.fill") }

    // Actions
    static var computedIcon: Image { .init(systemName: "function") }
    static var editIcon: Image { .init(systemName: "pencil") }
    static var saveIcon: Image { .init(systemName: "checkmark.circle.fill") }
    static var cancelIcon: Image { .init(systemName: "xmark.circle.fill") }
    static var dateIcon: Image { .init(systemName: "calendar") }
    static var resetIcon: Image { .init(systemName: "arrow.clockwise") }
}
