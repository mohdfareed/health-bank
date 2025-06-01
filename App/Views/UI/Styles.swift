import SwiftUI

// MARK: Data Sources
// ============================================================================

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

// MARK: Logos
// ============================================================================

extension ShapeStyle where Self == Color {
    public static var logoGradient: LinearGradient {
        LinearGradient(
            colors: [.logoPrimary, .logoSecondary],
            startPoint: .bottom, endPoint: .top
        )
    }
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

var HealthKitLogo: some View {
    Image.healthKit
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundStyle(Color.healthKit)
}
