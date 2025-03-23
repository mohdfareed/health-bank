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

    init() throws {
        _ = try! AppDataStore.initializeContainer(
            configurations: AppDataStore.defaultConfig,
            HealthKitStoreConfiguration()
        )

        let settings = try AppSettings.singleton(in: AppDataStore.container.mainContext)
        var calendar = Calendar.current
        calendar.firstWeekday = settings.startOfWeek.rawValue
        try HealthKitService.enable()
        self.logger.debug("App initialized.")
    }

    var body: some Scene {
        WindowGroup {
            // DashboardView().modelContainer(AppDataStore.container)
        }
    }
}

#Preview {
    // DashboardView().modelContainer(
    //     try! AppDataStore.initializeContainer(
    //         configurations: AppDataStore.previewConfig
    //     )
    // )
}
