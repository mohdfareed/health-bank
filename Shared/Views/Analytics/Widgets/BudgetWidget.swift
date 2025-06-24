import Charts
import SwiftData
import SwiftUI

// MARK: - Budget Overview Widget
// ============================================================================

public struct BudgetWidget: View {
    @BudgetAnalytics var analytics: BudgetService?

    public init(analytics: BudgetAnalytics) {
        self._analytics = analytics
    }

    public var body: some View {
        DashboardCard(
            title: "Calories",
            icon: .calories, color: .calories
        ) {
            if let budget = analytics {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        CalorieContent(data: budget)
                        BudgetContent(data: budget)
                        CreditContent(data: budget)
                    }
                    Spacer()
                    budget.progress(color: .calories, icon: .calories)
                        .font(.title)
                        .frame(maxWidth: 80)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        } destination: {
        }
        .animation(.default, value: analytics == nil)
        // Auto-refresh when budget-related data changes
        .refreshOnHealthDataChange(for: [.dietaryCalories, .bodyMass]) {
            await $analytics.reload(at: Date())
        }
    }

    @ViewBuilder
    private func CalorieContent(data: BudgetService) -> some View {
        let formatter = CalorieFieldDefinition().formatter
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ValueView(
                measurement: .init(
                    baseValue: .constant(data.remaining),
                    definition: UnitDefinition<UnitEnergy>.calorie
                ),
                icon: nil, tint: nil, format: formatter
            )
            .fontWeight(.bold)
            .font(.title)
            .foregroundColor(data.remaining ?? 0 >= 0 ? .primary : .red)
        }
    }

    @ViewBuilder
    private func BudgetContent(data: BudgetService) -> some View {
        let formatter = CalorieFieldDefinition().formatter
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Image.maintenance
                .symbolEffect(
                    .rotate.byLayer,
                    options: data.calories.isValid
                        ? .nonRepeating
                        : .repeat(.periodic(delay: 5))
                )
                .foregroundColor(.calories)
                .font(.subheadline)
                .frame(width: 24, height: 24, alignment: .leading)

            Text(data.calories.currentIntake ?? 0, format: formatter)
                .fontWeight(.bold)
                .font(.headline)
                .foregroundColor(.secondary)

            Text("/")
                .font(.headline)
                .foregroundColor(.secondary)

            ValueView(
                measurement: .init(
                    baseValue: .constant(data.budget),
                    definition: UnitDefinition<UnitEnergy>.calorie
                ),
                icon: nil, tint: nil, format: formatter
            )
            .fontWeight(.bold)
            .font(.headline)
            .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func CreditContent(data: BudgetService) -> some View {
        let formatter = CalorieFieldDefinition().formatter
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Image.credit
                .foregroundColor(.accent)
                .font(.headline)
                .frame(width: 24, height: 24, alignment: .leading)

            if let credit = data.credit {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(credit),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil, format: formatter
                )
                .fontWeight(.bold)
                .font(.headline)
                .foregroundColor(credit >= 0 ? .green : .red)
            } else {
                Text("No data available")
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
        }
    }
}
