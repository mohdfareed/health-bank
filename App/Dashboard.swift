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
    @Environment(\.widgetDataRepository) private var widgetData
    let goals: UserGoals

    init(_ goals: UserGoals) {
        self.goals = goals
    }

    var body: some View {
        List {
            BudgetComponent(style: .dashboard)
            MacrosComponent(style: .dashboard)
            OverviewComponent()
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
        // Pass goals configuration to the repository for adjustment calculations
        await widgetData.refreshAllData(with: goals)
    }
}
