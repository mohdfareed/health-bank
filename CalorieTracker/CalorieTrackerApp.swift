import SwiftData
import SwiftUI

struct DataStore {
    static let container: ModelContainer = {
        do {
            return try ModelContainer(
                for: Schema([
                    Settings.self,
                    AppState.self,
                    // App models
                    CalorieEntry.self,
                    CalorieBudget.self,
                ]))
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    static let previewContainer: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(
                for: Schema([
                    Settings.self,
                    AppState.self,
                    // App models
                    CalorieEntry.self,
                    CalorieBudget.self,
                ]), configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}

@main
struct CalorieTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView(
                viewModel: DashboardVM(
                    context: DataStore.container.mainContext,
                    budget: CalorieBudget(
                        17_500,
                        lasts: 7,
                        starting: Date.now,
                        named: "Weekly Budget"
                    )
                ))
        }
        .modelContainer(DataStore.container)
    }
}
