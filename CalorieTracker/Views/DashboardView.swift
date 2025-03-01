import SwiftData
import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel: DashboardVM
    @State private var isShowingLogEntry = false

    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var budgets: [CalorieBudget]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    BudgetView(viewModel: self.viewModel.budgetVM)
                    DailyBudgetView(self.viewModel.budgetVM)
                    Button("Log Entry") {
                        isShowingLogEntry = true
                    }
                    .padding()
                }
                .navigationTitle(Text("Dashboard"))
                .sheet(isPresented: $isShowingLogEntry) {
                    LogEntryView(
                        viewModel: LogEntryVM(
                            caloriesService: CaloriesService(context: modelContext)))
                }
                .padding()
            }
        }
    }
}
#Preview {
    let vm = DashboardVM(
        context: DataStore.previewContainer.mainContext,
        budget: CalorieBudget(
            17_500,
            lasts: 7,
            starting: Date.now,
            named: "Weekly Budget"
        )
    )

    DashboardView(viewModel: vm).modelContainer(DataStore.previewContainer)
}
