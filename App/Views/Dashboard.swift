import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.healthKit) private var healthKitService

    private let analyticsService = AnalyticsService()
    private let budgetService = BudgetService()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Budget Overview Widget
                    BudgetOverviewWidget(
                        healthKitService: healthKitService,
                        analyticsService: analyticsService,
                        budgetService: budgetService
                    )

                    // Maintenance Discovery Widget
                    MaintenanceDiscoveryWidget(
                        healthKitService: healthKitService,
                        analyticsService: analyticsService
                    )
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}
