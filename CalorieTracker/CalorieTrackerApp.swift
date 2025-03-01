import SwiftData
import SwiftUI

struct DataStore {
    @Environment(\.modelContext) private var context: ModelContext

    static let container: ModelContainer = {
        let schema: Schema = Schema([
            Settings.self,
            AppState.self,
            // App models
            CalorieEntry.self,
            CalorieBudget.self,
        ])

        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}

@main
struct CalorieTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(DataStore.container)
    }
}
