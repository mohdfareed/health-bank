import HealthVaultsShared
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Query.Singleton var goals: UserGoals

    init(goalsID: UUID) {
        self._goals = .init(goalsID)
    }

    var body: some View {
        NavigationStack {
            DashboardWidgets(goals)
                .navigationTitle("Dashboard")
        }
    }
}

struct DashboardWidgets: View {
    @BudgetAnalytics private var budget: BudgetService?
    @MacrosAnalytics private var macros: MacrosAnalyticsService?

    init(_ goals: UserGoals) {
        _budget = BudgetAnalytics(adjustment: goals.adjustment)
        _macros = MacrosAnalytics(
            budgetAnalytics: _budget, adjustments: goals.macros
        )
    }

    var body: some View {
        List {
            BudgetWidget(analytics: $budget)
            MacrosWidget(analytics: $macros)
            OverviewWidget(analytics: $macros)
        }
        .refreshable {
            await refresh()
        }
        .onAppear {
            Task {
                await refresh()
            }
        }
        // Modern SwiftUI auto-refresh when HealthKit data changes
        .refreshOnHealthDataChange(
            for: [.dietaryCalories, .protein, .carbs, .fat, .bodyMass]
        ) {
            await refresh()
        }
    }

    func refresh() async {
        await $budget.reload(at: Date())
        await $macros.reload(at: Date())
    }
}
