import OSLog
import SwiftData
import SwiftUI

extension Logger {
    private static var defaultSubsystem: String = {
        Bundle.main.bundleIdentifier ?? "Debug.CalorieTracker"
    }()

    init(for category: String) {
        self.init(subsystem: Logger.defaultSubsystem, category: category)
    }

    init<T>(for category: T.Type) {
        self.init(subsystem: Logger.defaultSubsystem, category: "\(T.self)")
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
struct CalorieTrackerApp: App {
    internal let logger = Logger(for: CalorieTrackerApp.self)

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
