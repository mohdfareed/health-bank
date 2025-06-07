import SwiftUI

// MARK: Colors
// ============================================================================

extension Color {
    static var accent: Color { .init("Accent") }

    // Data Sources
    static var healthKit: Color { .pink }
    static var cloud: Color { .blue }
    static var unknownApp: Color { .gray }

    // Data Records
    static var calories: Color { .init("Calorie") }
    static var weight: Color { .purple }

    // Dietary Energy
    static var dietaryCalorie: Color { .red }
    static var macros: Color { .indigo }
    static var protein: Color { .orange }
    static var carbs: Color { .yellow }
    static var fat: Color { .green }

    // Activity
    static var activeCalorie: Color { .green }
    static var duration: Color { .orange }
}

// MARK: Iconography
// ============================================================================

extension Image {
    static var logo: Image { .init("logo") }
    static var appSettings: Image { .init("gear.badge.ellipsis") }

    // Apple Health
    static var appleHealth: Image { .init("AppleHealth") }
    static var appleHealthBadge: Image { .init("AppleHealthBadge") }

    // Data Sources
    static var cloud: Image { .init(systemName: "icloud.fill") }
    static var healthKit: Image { .init(systemName: "heart.fill") }
    static var unknownApp: Image { .init(systemName: "questionmark.app.fill") }

    // Data Records
    static var calories: Image { .init(systemName: "flame.fill") }
    static var weight: Image { .init(systemName: "scalemass") }

    // Dietary Energy
    static var dietaryCalorie: Image { .init("apple.fill") }
    static var macros: Image { .init(systemName: "chart.pie") }
    static var protein: Image { .init("meat") }
    static var fat: Image { .init("avocado") }
    static var carbs: Image { .init("bread") }

    // Activity
    static var activeCalorie: Image { .init(systemName: "figure.run") }
    static var duration: Image { .init(systemName: "timer") }

    // Workouts
    static var cardio: Image { .init(systemName: "figure.walk.treadmill") }
    static var weightlifting: Image {
        .init(systemName: "figure.strengthtraining.traditional")
    }
    static var cycling: Image { .init(systemName: "figure.outdoor.cycle") }
    static var swimming: Image { .init(systemName: "figure.pool.swim") }
    static var dancing: Image { .init(systemName: "figure.dance") }
    static var boxing: Image { .init(systemName: "figure.boxing") }
    static var martialArts: Image { .init(systemName: "figure.kickboxing") }
}

// MARK: Miscellaneous
// ============================================================================

extension Image {
    var asText: Text {
        Text("\(self)")
            .font(.footnote.bold())
    }

    static var appleHealthLogo: some View {
        Image.appleHealth
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 48)
            .padding(1).background(Color.secondary)  // Stroke
            .cornerRadius(12)  // Stroke corner radius
    }
}

extension DataSource {
    var icon: Image {
        switch self {
        case .app:
            return .logo
        case .healthKit:
            return .healthKit
        case .other:
            return .unknownApp
        }
    }

    var color: Color {
        switch self {
        case .app:
            return .accent
        case .healthKit:
            return .healthKit
        case .other:
            return .unknownApp
        }
    }
}

extension WorkoutActivity {
    var icon: Image {
        switch self {
        case .cardio:
            return .cardio
        case .cycling:
            return .cycling
        case .swimming:
            return .swimming
        case .weightlifting:
            return .weightlifting
        case .dancing:
            return .dancing
        case .boxing:
            return .boxing
        case .martialArts:
            return .martialArts
        }
    }
}
