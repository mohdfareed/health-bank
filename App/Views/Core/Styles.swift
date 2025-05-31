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
