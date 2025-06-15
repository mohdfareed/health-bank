import Charts
import SwiftData
import SwiftUI

// MARK: - Macros Overview Widget
// ============================================================================

struct MacrosWidget: View {
    let healthKitService: HealthKitService
    let analyticsService: AnalyticsService
    @Binding var refreshing: Bool

    @Query.Singleton
    private var goals: UserGoals
    @State private var proteinBudget: BudgetService?
    @State private var carbsBudget: BudgetService?
    @State private var fatBudget: BudgetService?

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
            title: "Macros Budget",
            icon: .macros, color: .macros
        ) {
            if let protein = proteinBudget, let carbs = carbsBudget, let fat = fatBudget {
                HStack {
                    Spacer()
                    BudgetContent(data: protein, color: .protein, icon: .protein)
                    Spacer()
                    Divider()
                    Spacer()
                    BudgetContent(data: carbs, color: .carbs, icon: .carbs)
                    Spacer()
                    Divider()
                    Spacer()
                    BudgetContent(data: fat, color: .fat, icon: .fat)
                    Spacer()
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        } destination: {
        }

        .animation(.default, value: goals)
        .animation(.default, value: proteinBudget == nil)
        .animation(.default, value: carbsBudget == nil)
        .animation(.default, value: fatBudget == nil)

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
    private func BudgetContent(data: BudgetService, color: Color, icon: Image) -> some View {
        VStack {
            if let remaining = data.remaining {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(remaining),
                        definition: UnitDefinition<UnitMass>.macro
                    ),
                    icon: nil, tint: nil, format: .number
                )
                .fontWeight(.bold)
                .font(.title)
                .foregroundColor(remaining >= 0 ? .primary : .red)

                if let credit = data.credit {
                    ValueView(
                        measurement: .init(
                            baseValue: .constant(credit),
                            definition: UnitDefinition<UnitMass>.macro
                        ),
                        icon: nil, tint: nil, format: .number
                    )
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .foregroundColor(credit >= 0 ? .green : .red)
                } else if let smoothed = data.smoothedIntake {
                    ValueView(
                        measurement: .init(
                            baseValue: .constant(smoothed),
                            definition: UnitDefinition<UnitMass>.macro
                        ),
                        icon: nil, tint: nil, format: .number
                    )
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .foregroundColor(smoothed >= 0 ? .green : .red)
                }
            } else {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(data.intake),
                        definition: UnitDefinition<UnitMass>.macro
                    ),
                    icon: nil, tint: nil, format: .number
                )
                .fontWeight(.bold)
                .font(.title)
                .foregroundColor(.primary)
            }

            data.progress(color: color, icon: icon)
                .font(.subheadline.bold())
                .frame(maxWidth: 50)
        }
    }

    private func loadData() async {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!

        // Get protein data for the past 7 days
        let proteinData = await healthKitService.fetchStatistics(
            for: .protein,
            from: startDate, to: endDate,
            interval: .daily, options: .cumulativeSum
        )

        // Get carbs data for the past 7 days
        let carbsData = await healthKitService.fetchStatistics(
            for: .carbs,
            from: startDate, to: endDate,
            interval: .daily, options: .cumulativeSum
        )

        // Get fat data for the past 7 days
        let fatData = await healthKitService.fetchStatistics(
            for: .fat,
            from: startDate, to: endDate,
            interval: .daily, options: .cumulativeSum
        )

        // Create services
        let protein = BudgetService(
            analytics: analyticsService, intakes: proteinData, alpha: 0.25,
            budget: goals.macros?.protein
        )
        let carbs = BudgetService(
            analytics: analyticsService, intakes: carbsData, alpha: 0.25,
            budget: goals.macros?.carbs
        )
        let fat = BudgetService(
            analytics: analyticsService, intakes: fatData, alpha: 0.25,
            budget: goals.macros?.fat
        )

        await MainActor.run {
            withAnimation(.default) {
                self.proteinBudget = protein
                self.carbsBudget = carbs
                self.fatBudget = fat
            }
        }
    }
}
