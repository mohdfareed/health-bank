import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(AppSettings.self) private var settings: AppSettings

    @State private var isLoggingCalories: Bool = false
    private let budgetName: String

    private var budget: String {
        self.settings.activeBudget = self.settings.activeBudget ?? self.budgetName
        return self.settings.activeBudget ?? self.budgetName
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
                    BudgetView(budget: self.budgetName, at: Date.now)
                    Button("Log Calories") {
                        self.isLoggingCalories = true
                    }
                    .padding()
                }
                .navigationTitle(Text("Dashboard"))
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

    init(budget: String? = nil) {
        self.budgetName = budget ?? CalorieBudgetService.defaultBudget.name
    }
}

#Preview {
    DashboardView(budget: "Preview Budget")
        .modelContainer(DataStore.previewContainer)
        .environment(\.modelContext, DataStore.previewContainer.mainContext)
        .environment(AppSettings())
        .environment(AppState())
}
