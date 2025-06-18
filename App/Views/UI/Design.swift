import SwiftUI

// MARK: Colors
// ============================================================================

extension Color {
    static var accent: Color { .init("Accent") }
    static var healthKit: Color { .pink }
    static var shortcuts: Color { .purple }
    static var foodNoms: Color { .calories }
    static var unknown: Color { .gray }

    // Data Records
    static var calories: Color { .init("Calorie") }
    static var weight: Color { .purple }

    // Dietary Energy
    static var macros: Color { .indigo }
    static var protein: Color {
        Color.red.mix(with: .brown, by: 0.1).mix(with: .black, by: 0.2)
    }
    static var carbs: Color { .orange }
    static var fat: Color { .green }
    static var alcohol: Color { .indigo }
}

// MARK: Iconography
// ============================================================================

extension Image {
    static var logo: Image { .init("logo.fill") }

    // Apple Health
    static var appleHealth: Image { .init("AppleHealth") }
    static var appleHealthBadge: Image { .init("AppleHealthBadge") }

    // Data Sources
    static var healthKit: Image { .init(systemName: "heart.fill") }
    static var shortcuts: Image {
        .init(systemName: "app.connected.to.app.below.fill")
            .symbolRenderingMode(.hierarchical)
    }
    static var foodNoms: Image { .init(systemName: "fork.knife") }
    static var unknownApp: Image {
        .init(systemName: "questionmark.app.dashed")
            .symbolRenderingMode(.hierarchical)
    }

    // Data Records
    static var calories: Image { .init(systemName: "flame.fill") }
    static var weight: Image { .init(systemName: "figure") }
    static var maintenance: Image {
        if #available(iOS 26, macOS 26, watchOS 26, *) {
            return .init(systemName: "flame.gauge.open")
                .symbolRenderingMode(.hierarchical)
        } else {
            return .init(systemName: "gauge.with.needle")
                .symbolRenderingMode(.hierarchical)
        }
    }
    static var credit: Image {
        .init(systemName: "creditcard.circle")
            .symbolRenderingMode(.hierarchical)
    }

    // Dietary Energy
    static var macros: Image { .init(systemName: "chart.pie") }
    static var protein: Image { .init("meat").symbolRenderingMode(.hierarchical) }
    static var fat: Image { .init("avocado").symbolRenderingMode(.hierarchical) }
    static var carbs: Image { .init("bread").symbolRenderingMode(.hierarchical) }
    static var alcohol: Image { .init(systemName: "wineglass") }
}

// MARK: Miscellaneous
// ============================================================================
extension Image {
    static var appleHealthLogo: some View {
        Image.appleHealth
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 48)
            .padding(1).background(.quinary)  // Stroke
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
        case .shortcuts:
            return .shortcuts
        case .foodNoms:
            return .foodNoms
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
        case .shortcuts:
            return .shortcuts
        case .foodNoms:
            return .foodNoms
        case .other:
            return .unknown
        }
    }
}

// MARK: Extensions
// ============================================================================

extension Image {
    var asText: Text {
        Text("\(self)").font(.footnote.bold())
    }
}
