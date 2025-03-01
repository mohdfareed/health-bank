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
            DashboardView()
        }
        .modelContainer(DataStore.container)
    }
}
