import SwiftUI

// MARK: Colors
// ============================================================================

extension Color {
    static var accent: Color { .init("Accent") }

    // Data Sources
    static var local: Color { .accent }
    static var healthKit: Color { .pink }
    static var cloud: Color { .blue }

    // Data Records
    static var calories: Color { .init("Calorie") }
    static var dietaryCalorie: Color { .red }
    static var activeCalorie: Color { .green }
    static var restingCalorie: Color { .indigo }
    static var weight: Color { .purple }
    static var duration: Color { .orange }

    // Macros
    static var macros: Color { .indigo }
    static var protein: Color { .purple }
    static var carbs: Color { .green }
    static var fat: Color { .yellow }
}

// MARK: Iconography
// ============================================================================

extension Image {
    static var logo: Image { .init("Logo") }

    // Data Sources
    static var local: Image? { logo }
    static var cloud: Image { .init(systemName: "icloud.fill") }
    static var healthKit: Image { .init(systemName: "heart.fill") }

    // Data Records
    static var calories: Image { .init(systemName: "flame.fill") }
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
