import OSLog
import SwiftData
import SwiftUI

struct AppLogger {
    private static let defaultSubsystem: String = {
        Bundle.main.bundleIdentifier ?? "Debug.HealthTracker"
    }()

    private init() {}

    static func new(for category: String) -> Logger {
        return Logger(
            subsystem: AppLogger.defaultSubsystem, category: category
        )
    }

    static func new<T>(for category: T.Type) -> Logger {
        return Logger(
            subsystem: AppLogger.defaultSubsystem, category: "\(T.self)"
        )
    }
}

struct AppDataStore {
    private static var schema: Schema {
        Schema([
            AppSettings.self,
            AppState.self,
            // Date models
            ConsumedCalories.self,
            BurnedCalories.self,
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
struct HealthTrackerApp: App {
    internal let logger = AppLogger.new(for: HealthTrackerApp.self)

    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var appSettings: [AppSettings]
    @Query private var appState: [AppState]

    var settings: AppSettings {
        guard let settings = appSettings.first else {
            let defaultSettings = AppSettings()
            self.logger.info("Creating default settings.")
            self.modelContext.insert(defaultSettings)
            return defaultSettings
        }

        self.logger.debug("Loaded settings.")
        return settings
    }

    var state: AppState {
        guard let state = appState.first else {
            let defaultState = AppState()
            self.logger.info("Creating default state.")
            self.modelContext.insert(defaultState)
            return defaultState
        }

        self.logger.debug("Loaded state.")
        return state
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
