import Charts
import SwiftData
import SwiftUI

// MARK: - Budget Overview Widget
// ============================================================================

struct BudgetWidget: View {
    let healthKitService: HealthKitService
    let analyticsService: AnalyticsService
    @Binding var refreshing: Bool

    @Query.Singleton
    private var goals: UserGoals
    @State private var budget: BudgetService?
    @State private var maintenance: MaintenanceService?

    init(
        _ id: UUID,
        healthKit: HealthKitService,
        analytics: AnalyticsService,
        refreshing: Binding<Bool> = .constant(false)
    ) {
        self._goals = .init(id)
        self.healthKitService = healthKit
        self.analyticsService = analytics
        self._refreshing = refreshing
    }

    var body: some View {
        DashboardCard(
            title: "Calorie Budget",
            icon: .calories, color: .calories
        ) {
            if let budget = budget, let maintenance = maintenance {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        BudgetContent(data: budget)
                        CreditContent(data: budget)
                        MaintenanceContent(data: maintenance)
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

        .animation(.default, value: goals)
        .animation(.default, value: budget == nil)
        .animation(.default, value: maintenance == nil)

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
    private func BudgetContent(data: BudgetService) -> some View {
        HStack(alignment: .firstTextBaseline) {
            if let remaining = data.remaining {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(remaining),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil, format: .number
                )
                .fontWeight(.bold)
                .font(.title)
                .foregroundColor(remaining >= 0 ? .primary : .red)

                Text("remaining")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(data.intake),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil, format: .number
                )
                .fontWeight(.bold)
                .font(.title)
                .foregroundColor(.primary)

                Text("consumed")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func CreditContent(data: BudgetService) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            if let credit = data.credit {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(credit),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil, format: .number
                )
                .fontWeight(.bold)
                .font(.title2)
                .foregroundColor(credit >= 0 ? .green : .red)

                Text("credit")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            } else if let smoothed = data.smoothedIntake {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(smoothed),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil, format: .number
                )
                .fontWeight(.bold)
                .font(.title2)
                .foregroundColor(smoothed >= 0 ? .green : .red)

                Text("avg. intake")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            } else {
                Text("No calorie credit")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func MaintenanceContent(data: MaintenanceService) -> some View {
        HStack(alignment: .firstTextBaseline) {
            if let maintenance = data.maintenance {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(maintenance),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil, format: .number
                )
                .fontWeight(.bold)
                .font(.title2)
                .foregroundColor(.indigo)

                Text("maintenance")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(data.weeklyTrend),
                        definition: UnitDefinition<UnitMass>.weight
                    ),
                    icon: nil, tint: nil, format: .number
                )
                .fontWeight(.bold)
                .font(.title2)
                .foregroundStyle(data.weeklyTrend >= 0 ? .green : Color.red)

                Text("per week")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func loadData() async {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!
        let weightStartDate = Calendar.current.date(byAdding: .day, value: -14, to: endDate)!

        // Get calorie data for the past 7 days
        let calorieData = await healthKitService.fetchStatistics(
            for: .dietaryCalories,
            from: startDate,
            to: endDate,
            interval: .daily,
            options: .cumulativeSum
        )

        // Get weight data for the past 14 days
        let weightData = await healthKitService.fetchStatistics(
            for: .bodyMass,
            from: weightStartDate,
            to: endDate,
            interval: .daily,
            options: .discreteAverage
        )

        // Create services
        let newBudget = BudgetService(
            analytics: analyticsService, intakes: calorieData, alpha: 0.25,
            budget: goals.calories
        )
        let newMaintenance = MaintenanceService(
            analytics: analyticsService, budget: newBudget,
            weights: weightData, rho: 7700
        )

        await MainActor.run {
            withAnimation(.default) {
                budget = newBudget
                maintenance = newMaintenance
            }
        }
    }
}
