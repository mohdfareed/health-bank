import OSLog
import SwiftData
import SwiftUI

struct DataStore {
    private static var schema: Schema {
        Schema([
            Settings.self,
            AppState.self,
            // App models
            CalorieEntry.self,
            CalorieBudget.self,
        ])
    }

    static let container: ModelContainer = {
        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    static let previewContainer: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }()
}

struct AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Debug.CalorieTracker"

    /// Create a new logger with the given category.
    /// - Parameter category: The category for the logger.
    /// - Returns: A new logger instance.
    static func new(category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}

@main
struct CalorieTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView(
                viewModel: DashboardVM()
            )
        }
        .modelContainer(DataStore.container)
    }
}
