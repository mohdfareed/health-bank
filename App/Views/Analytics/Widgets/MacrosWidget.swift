import Charts
import SwiftData
import SwiftUI

// MARK: - Macros Overview Widget
// ============================================================================

struct MacrosWidget: View {
    @MacrosAnalytics var analytics: MacrosAnalyticsService?

    var body: some View {
        DashboardCard(
            title: "Macros",
            icon: .macros, color: .macros
        ) {
            if analytics != nil {
                HStack {
                    BudgetContent(ring: .protein)
                    Spacer()
                    Divider()
                    Spacer()
                    BudgetContent(ring: .carbs)
                    Spacer()
                    Divider()
                    Spacer()
                    BudgetContent(ring: .fat)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        } destination: {
        }

        .animation(.default, value: analytics == nil)
        .animation(.default, value: analytics?.protein == nil)
        .animation(.default, value: analytics?.carbs == nil)
        .animation(.default, value: analytics?.fat == nil)
    }

    @ViewBuilder
    private func BudgetContent(
        ring: MacrosAnalyticsService.MacroRing
    ) -> some View {
        let formatter = ProteinFieldDefinition().formatter
        VStack(alignment: .center) {
            ValueView(
                measurement: .init(
                    baseValue: .constant(remaining(ring: ring)),
                    definition: UnitDefinition<UnitMass>.macro
                ),
                icon: nil, tint: nil, format: formatter
            )
            .fontWeight(.bold)
            .font(.title)
            .foregroundColor(remaining(ring: ring) ?? 0 >= 0 ? .primary : .red)

            MacroContent(ring: ring)

            analytics?.progress(ring)
                .font(.subheadline)
                .frame(maxWidth: 50)
        }
    }

    @ViewBuilder
    private func MacroContent(
        ring: MacrosAnalyticsService.MacroRing,
    ) -> some View {
        let formatter = ProteinFieldDefinition().formatter
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(intake(ring: ring) ?? 0, format: formatter)
                .fontWeight(.bold)
                .font(.headline)
                .foregroundColor(.secondary)

            Text("/")
                .font(.headline)
                .foregroundColor(.secondary)

            ValueView(
                measurement: .init(
                    baseValue: .constant(budget(ring: ring)),
                    definition: UnitDefinition<UnitMass>.macro
                ),
                icon: nil, tint: nil, format: formatter
            )
            .fontWeight(.bold)
            .font(.headline)
            .foregroundColor(.secondary)
        }
    }

    private func intake(ring: MacrosAnalyticsService.MacroRing) -> Double? {
        switch ring {
        case .protein:
            return analytics?.protein.currentIntake
        case .carbs:
            return analytics?.carbs.currentIntake
        case .fat:
            return analytics?.fat.currentIntake
        }
    }

    private func budget(ring: MacrosAnalyticsService.MacroRing) -> Double? {
        switch ring {
        case .protein:
            return analytics?.budgets?.protein
        case .carbs:
            return analytics?.budgets?.carbs
        case .fat:
            return analytics?.budgets?.fat
        }
    }

    private func remaining(ring: MacrosAnalyticsService.MacroRing) -> Double? {
        switch ring {
        case .protein:
            return analytics?.remaining?.protein
        case .carbs:
            return analytics?.remaining?.carbs
        case .fat:
            return analytics?.remaining?.fat
        }
    }

    private func icon(ring: MacrosAnalyticsService.MacroRing) -> Image? {
        switch ring {
        case .protein:
            return .protein
        case .carbs:
            return .carbs
        case .fat:
            return .fat
        }
    }

    private func color(ring: MacrosAnalyticsService.MacroRing) -> Color {
        switch ring {
        case .protein:
            return .protein
        case .carbs:
            return .carbs
        case .fat:
            return .fat
        }
    }
}
