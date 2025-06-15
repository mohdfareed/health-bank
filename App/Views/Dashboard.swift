import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.healthKit) private var healthKitService
    @AppStorage(.userGoals) private var goalsID: UUID
    private let analyticsService = AnalyticsService()

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    BudgetWidget(
                        goalsID,
                        healthKit: healthKitService,
                        analytics: analyticsService,
                    )

                    // MaintenanceWidget(
                    //     healthKitService: healthKitService,
                    //     analyticsService: analyticsService
                    // )
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}
