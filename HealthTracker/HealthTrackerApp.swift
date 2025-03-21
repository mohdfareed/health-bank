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

@main
struct HealthTrackerApp: App {
    internal let logger = AppLogger.new(for: HealthTrackerApp.self)

    static let schema = Schema([
        AppSettings.self,
        AppState.self,
        // Date models
        ConsumedCalories.self,
        BurnedCalories.self,
    ])

    var body: some Scene {
        WindowGroup {
            DashboardView().modelContainer(
                try! AppDataStore.container(
                    HealthTrackerApp.schema,
                    configurations:
                        HealthKitStore.Configuration()
                )
            )
        }
    }
}

#Preview {
    DashboardView().modelContainer(
        AppDataStore.previewContainer(HealthTrackerApp.schema)
    )
}
