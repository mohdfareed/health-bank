import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Environment(\.healthKit) private var healthKitService
    @AppStorage(.userGoals) private var goalsID: UUID
    private let analyticsService = AnalyticsService()

    @State private var refreshing = true

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    BudgetWidget(
                        goalsID,
                        healthKit: healthKitService,
                        analytics: analyticsService,
                        refreshing: $refreshing
                    )

                    MacrosWidget(
                        goalsID,
                        healthKit: healthKitService,
                        analytics: analyticsService,
                        refreshing: $refreshing
                    )
                }
                .padding()
            }
            .navigationTitle("Dashboard")

            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        refreshing.toggle()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}
