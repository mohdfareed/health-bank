import Charts
import SwiftData
import SwiftUI

// MARK: - Budget Overview Widget
// ============================================================================

struct BudgetWidget: View {
    @BudgetAnalytics var budget: BudgetService?
    @Binding var refreshing: Bool

    init(
        _ adjustment: Double? = nil,
        refreshing: Binding<Bool> = .constant(false)
    ) {
        self._refreshing = refreshing
        self._budget = .init(adjustment: adjustment)
    }

    var body: some View {
        DashboardCard(
            title: "Calories",
            icon: .calories, color: .calories
        ) {
            if let budget = budget {
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

        .animation(.default, value: refreshing)
        .animation(.default, value: budget == nil)

        .onAppear {
            Task {
                await $budget.reload(at: Date())
            }
        }

        .onChange(of: refreshing) {
            Task {
                await $budget.reload(at: Date())
            }
        }
    }

    @ViewBuilder
    private func CalorieContent(data: BudgetService) -> some View {
        let formatter = CalorieFieldDefinition().formatter
        HStack(alignment: .firstTextBaseline) {
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
        Label {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
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
        } icon: {
            Image.maintenance
                .symbolEffect(
                    .rotate.byLayer,
                    options: data.calories.isValid
                        ? .nonRepeating
                        : .repeat(.periodic(delay: 2.5))
                )
                .foregroundColor(.calories)
                .font(.headline)
        }
    }

    @ViewBuilder
    private func CreditContent(data: BudgetService) -> some View {
        let formatter = CalorieFieldDefinition().formatter
        Label {
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
        } icon: {
            Image.credit
                .foregroundColor(.accent)
                .font(.headline)
        }
    }
}
