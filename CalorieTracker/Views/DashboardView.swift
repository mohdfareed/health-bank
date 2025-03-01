import SwiftData
import SwiftUI

struct DashboardView: View {
    @State var viewModel: DashboardViewModel
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var budgets: [CalorieBudget]

    init() {
        self.viewModel = DashboardViewModel()
    }

    var body: some View {
        let budget = self.budgets.first ?? CalorieBudget(17_500, lasts: 7, named: "Weekly Budget")
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    BudgetView(context: self.modelContext, budget: budget)
                    DailyBudgetView(context: self.modelContext, budget: budget)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardView().modelContainer(DataStore.previewContainer)
}
