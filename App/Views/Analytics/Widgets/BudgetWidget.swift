import Charts
import SwiftData
import SwiftUI

// MARK: - Budget Overview Widget
// ============================================================================

struct BudgetWidget: View {
    let healthKitService: HealthKitService
    let analyticsService: AnalyticsService

    @Query.Singleton var goals: UserGoals

    @State private var budget: BudgetService?
    @State private var maintenance: MaintenanceService?

    init(_ id: UUID, healthKit: HealthKitService, analytics: AnalyticsService) {
        self._goals = .init(id)
        self.healthKitService = healthKit
        self.analyticsService = analytics
    }

    var body: some View {
        DashboardCard(
            title: "Calorie Budget",
            icon: .calories, color: .calories
        ) {
            if let budget = budget, let maintenance = maintenance {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        BudgetContent(data: budget)
                        CreditContent(data: budget)
                        MaintenanceContent(data: maintenance)
                    }
                    Spacer()
                    ProgressIndicator(data: budget)
                        .frame(maxWidth: 80, maxHeight: 80)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        } destination: {
        }
        .task {
            await loadBudgetData()
        }
    }

    @ViewBuilder
    private func BudgetContent(data: BudgetService) -> some View {
        HStack(alignment: .firstTextBaseline) {
            ValueView(
                measurement: .init(
                    baseValue: .constant(data.remaining),
                    definition: UnitDefinition<UnitEnergy>.calorie
                ),
                icon: nil, tint: nil, format: .number
            )
            .fontWeight(.bold)
            .font(.largeTitle)
            .foregroundColor(data.remaining >= 0 ? .primary : .red)

            Text("left")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func CreditContent(data: BudgetService) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ValueView(
                measurement: .init(
                    baseValue: .constant(data.credit),
                    definition: UnitDefinition<UnitEnergy>.calorie
                ),
                icon: nil, tint: nil, format: .number
            )
            .fontWeight(.bold)
            .font(.title2)
            .foregroundColor(data.credit >= 0 ? .green : .red)

            Text("credit")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.leading, 8)
        }
    }

    @ViewBuilder
    private func MaintenanceContent(data: MaintenanceService) -> some View {
        HStack(alignment: .firstTextBaseline) {
            ValueView(
                measurement: .init(
                    baseValue: .constant(data.maintenance),
                    definition: UnitDefinition<UnitEnergy>.calorie
                ),
                icon: nil, tint: nil, format: .number
            )
            .fontWeight(.bold)
            .font(.title2)

            Text("per day")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func ProgressIndicator(data: BudgetService) -> some View {
        ProgressRing(
            value: data.budget,
            progress: data.budget - data.remaining,
            color: data.remaining >= 0 ? .accent : .red,
            tip: data.budget + data.credit,
            tipColor: data.credit >= 0 ? .green : .red,
            width: 12
        )
    }

    private func loadBudgetData() async {
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
        budget = .init(
            analytics: analyticsService, intakes: calorieData, alpha: 0.25,
            budget: goals.calories ?? 2000
        )
        maintenance = .init(
            analytics: analyticsService, budget: budget!,
            weights: weightData, rho: 7700
        )
    }
}
