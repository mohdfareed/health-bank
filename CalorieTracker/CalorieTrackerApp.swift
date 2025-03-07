import OSLog
import SwiftData
import SwiftUI

struct AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "Debug.CalorieTracker"

    /// Create a new logger with the given category.
    /// - Parameter category: The category for the logger.
    /// - Returns: A new logger instance.
    static func create(for category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}

struct AppDataStore {
    private static var schema: Schema {
        Schema([
            AppSettings.self,
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

@main
struct CalorieTrackerApp: App {
    @Environment(\.modelContext) private var modelContext: ModelContext

    internal let logger = AppLogger.create(category: "\(CalorieTrackerApp.self)")

    var settings: AppSettings {
        let settings = FetchDescriptor<AppSettings>()

        do {
            let results = try self.modelContext.fetch(settings)
            if let settings = results.first {
                self.logger.debug("Loaded settings.")
                return settings
            }
        } catch {}

        let defaultSettings = AppSettings()
        self.logger.info("Creating default settings.")
        self.modelContext.insert(defaultSettings)
        return defaultSettings
    }

    var state: AppState {
        let state = FetchDescriptor<AppState>()

        do {
            let results = try self.modelContext.fetch(state)
            if let state = results.first {
                self.logger.debug("Loaded app state.")
                return state
            }
        } catch {}

        let defaultState = AppState()
        self.logger.info("Creating default app state.")
        self.modelContext.insert(defaultState)
        return defaultState
    }

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .modelContainer(AppDataStore.container)
                .environment(\.modelContext, modelContext)
                .environment(settings)
                .environment(state)
        }
    }
}

#Preview {
    DashboardView().modelContainer(AppDataStore.previewContainer)
        .environment(\.modelContext, AppDataStore.previewContainer.mainContext)
        .environment(AppSettings())
        .environment(AppState())
}
