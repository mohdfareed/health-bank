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
            title: "Calorie Budget",
            icon: .calories, color: .calories
        ) {
            if let budget = budget {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
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

            Text("remaining")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.leading, 8)
        }
    }

    @ViewBuilder
    private func BudgetContent(data: BudgetService) -> some View {
        let formatter = CalorieFieldDefinition().formatter
        HStack(alignment: .firstTextBaseline) {
            ValueView(
                measurement: .init(
                    baseValue: .constant(data.calories.currentIntake),
                    definition: UnitDefinition<UnitEnergy>.calorie
                ),
                icon: nil, tint: nil, format: formatter
            )
            .fontWeight(.bold)
            .font(.headline)
            .foregroundColor(.secondary)

            Text("/")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.leading, 8)

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
            if let credit = data.credit {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(credit),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil, format: formatter
                )
                .fontWeight(.bold)
                .font(.title2)
                .foregroundColor(credit >= 0 ? .green : .red)
                Text("credit")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            } else {
                Text("No data for credit")
                    .foregroundColor(.secondary)
            }
        }
    }
}
