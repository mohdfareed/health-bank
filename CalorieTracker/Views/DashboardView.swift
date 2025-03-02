import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(AppSettings.self) private var settings: AppSettings
    @Query private var budgets: [CalorieBudget]

    @State private var isLoggingCalories: Bool = false
    private let budgetName: String

    private var activeBudget: CalorieBudget {
        guard let budget = self.budgets.first else {
            let defaultBudget = CalorieBudgetService.defaultBudget
            defaultBudget.name = self.budgetName
            self.budgetService.create(defaultBudget)
            return defaultBudget
        }
        return budget
    }

    private var caloriesService: CaloriesService {
        CaloriesService(modelContext)
    }
    private var budgetService: CalorieBudgetService {
        CalorieBudgetService(modelContext)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    BudgetView(budget: self.activeBudget, at: Date.now)
                    Button("Log Calories") {
                        self.isLoggingCalories = true
                    }
                    .padding()
                }
                .navigationTitle(Text("Dashboard"))
                // TODO: Add a button to navigate to the settings
                .padding()
                .sheet(
                    isPresented: $isLoggingCalories,
                    onDismiss: {
                    }
                ) {
                    CalorieEditorView(
                        caloriesService: self.caloriesService
                    )
                }
            }
        }
    }

    init(budget: String) {
        self._budgets = Query(CalorieBudgetService.query(budget))
        self.budgetName = budget
    }
}

#Preview {
    DashboardView(budget: "Preview Budget")
        .modelContainer(DataStore.previewContainer)
        .environment(\.modelContext, DataStore.previewContainer.mainContext)
        .environment(AppSettings())
        .environment(AppState())
}
