import SwiftData
import SwiftUI

struct DashboardView: View {
    // @State var viewModel: DashboardVM
    @State private var isShowingLogEntry = false

    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var budgets: [CalorieBudget]

    // init() {
    // }

    var body: some View {
        let budget = budgets.first ?? CalorieBudget(17_500, lasts: 7, named: "Weekly Budget")
        let viewModel = DashboardVM(context: self.modelContext, budget: budget)

        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    BudgetView(viewModel.budgetVM)
                    DailyBudgetView(viewModel.budgetVM)
                    Button("Log Entry") {
                        isShowingLogEntry = true
                    }
                    .padding()
                }
                .navigationTitle("Dashboard")
                .sheet(isPresented: $isShowingLogEntry) {
                    LogEntryView(
                        viewModel: LogEntryVM(
                            caloriesService: CaloriesService(context: modelContext)))
                }
            }
        }
    }
}
#Preview {
    DashboardView().modelContainer(DataStore.previewContainer)
}
