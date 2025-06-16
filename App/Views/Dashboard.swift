import SwiftData
import SwiftUI

struct DashboardView: View {
    @AppStorage(.userGoals) private var goalsID: UUID
    @State private var refreshing: Bool = false

    var body: some View {
        NavigationStack {
            List {
                DashboardWidgets(goalsID, refreshing: $refreshing)
            }
            .navigationTitle("Dashboard")
            .refreshable {
                refreshing.toggle()
            }
        }
    }
}

struct DashboardWidgets: View {
    @Query.Singleton var goals: UserGoals
    @Binding private var refreshing: Bool

    init(
        _ goalsID: UUID,
        refreshing: Binding<Bool> = .constant(false)
    ) {
        self._refreshing = refreshing
        self._goals = .init(goalsID)
    }

    var body: some View {
        let budget = BudgetWidget(
            goals.adjustment,
            refreshing: $refreshing
        )
        budget

        MacrosWidget(
            goals.macros,
            budgetAnalytics: budget.$budget,
            refreshing: $refreshing
        )

        OverviewWidget(
            goals.adjustment, goals.macros,
            refreshing: $refreshing
        )
    }
}
