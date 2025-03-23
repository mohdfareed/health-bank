// import SwiftData
// import SwiftUI

// struct DashboardView: View {
//     @Environment(\.modelContext) private var modelContext: ModelContext
//     @Environment(AppSettings.self) private var settings: AppSettings

//     @Query private var budgets: [CalorieBudget]
//     @State private var isLoggingCalories: Bool = false

//     private let budgetName: String
//     // private var budgetName: String {
//     //     self.settings.activeBudget ?? CalorieBudgetService.defaultBudget.name
//     // }

//     private var activeBudget: CalorieBudget {
//         self.settings.activeBudget = self.budgetName

//         guard let budget = self.budgets.first else {
//             let defaultBudget = CalorieBudgetService.defaultBudget
//             defaultBudget.name = self.budgetName
//             self.budgetService.create(defaultBudget)
//             return defaultBudget
//         }
//         return budget
//     }

//     private var caloriesService: CaloriesService {
//         CaloriesService(modelContext)
//     }
//     private var budgetService: CalorieBudgetService {
//         CalorieBudgetService(modelContext)
//     }

//     var body: some View {
//         let summary: HKActivitySummary = HKActivitySummary()
//         summary.activeEnergyBurned = 1000
//         summary.activeEnergyBurnedGoal = 1500
//         NavigationView {
//             HKActivityRingView(summary)
//             ScrollView {
//                 VStack(spacing: 16) {
//                     BudgetView(budget: self.activeBudget, at: Date.now)
//                     Button("Log Calories") {
//                         self.isLoggingCalories = true
//                     }
//                     .padding()
//                 }
//                 .navigationTitle(Text("Dashboard"))
//                 .padding()
//                 .sheet(
//                     isPresented: $isLoggingCalories,
//                     onDismiss: {
//                     }
//                 ) {
//                     CalorieEditorView(
//                         caloriesService: self.caloriesService
//                     )
//                 }

//                 // TODO: Add buttons to the bottom to go to settings and
//                 // other views, mirroring Apple Health.
//             }
//             .background(.background)  // TODO: Use secondary in light mode
//         }
//     }

//     init(budget: String? = nil) {
//         self.budgetName = budget ?? CalorieBudgetService.defaultBudget.name
//         self._budgets = Query(CalorieBudgetService.query(budgetName))
//         // self.settings.activeBudget = self.budgetName
//         // self._budgets = Query(CalorieBudgetService.query(self.budgetName))
//         // FIXME: properly link dashboard budget to settings
//     }
// }

// #Preview {
//     DashboardView(budget: "Preview Budget")
//         .modelContainer(DataStore.previewContainer)
//         .environment(\.modelContext, DataStore.previewContainer.mainContext)
//         .environment(AppSettings())
//         .environment(AppState())
// }
