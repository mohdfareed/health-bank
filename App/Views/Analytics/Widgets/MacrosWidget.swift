import Charts
import SwiftData
import SwiftUI

// MARK: - Macros Overview Widget
// ============================================================================

struct MacrosWidget: View {
    @MacrosAnalytics private var macrosBudget: MacrosAnalyticsService?
    @Binding var refreshing: Bool

    init(
        _ adjustments: CalorieMacros? = nil,
        budgetAnalytics: BudgetAnalytics,
        refreshing: Binding<Bool> = .constant(false)
    ) {
        self._refreshing = refreshing
        self._macrosBudget = .init(
            budgetAnalytics: budgetAnalytics,
            adjustments: adjustments
        )
    }

    var body: some View {
        DashboardCard(
            title: "Macros",
            icon: .macros, color: .macros
        ) {
            if macrosBudget != nil {
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

        .animation(.default, value: refreshing)
        .animation(.default, value: macrosBudget == nil)
        .animation(.default, value: macrosBudget?.protein == nil)
        .animation(.default, value: macrosBudget?.carbs == nil)
        .animation(.default, value: macrosBudget?.fat == nil)

        .onAppear {
            Task {
                await loadData()
            }
        }

        .onChange(of: refreshing) {
            Task {
                await loadData()
            }
        }
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

            macrosBudget?.progress(ring)
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
            return macrosBudget?.protein.currentIntake
        case .carbs:
            return macrosBudget?.carbs.currentIntake
        case .fat:
            return macrosBudget?.fat.currentIntake
        }
    }

    private func budget(ring: MacrosAnalyticsService.MacroRing) -> Double? {
        switch ring {
        case .protein:
            return macrosBudget?.budgets?.protein
        case .carbs:
            return macrosBudget?.budgets?.carbs
        case .fat:
            return macrosBudget?.budgets?.fat
        }
    }

    private func remaining(ring: MacrosAnalyticsService.MacroRing) -> Double? {
        switch ring {
        case .protein:
            return macrosBudget?.remaining?.protein
        case .carbs:
            return macrosBudget?.remaining?.carbs
        case .fat:
            return macrosBudget?.remaining?.fat
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

    private func loadData() async {
        await $macrosBudget.reload(at: Date())
    }
}
