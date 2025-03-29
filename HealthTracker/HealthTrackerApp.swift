import OSLog
import SwiftData
import SwiftUI

// struct AppDataStoreService {
//     private static var schema: Schema {
//         Schema([
//             AppSettings.self,
//             // Date models
//             ConsumedCalories.self,
//             BurnedCalories.self,
//         ])
//     }

//     /// The default app store configuration.
//     static var defaultConfig: ModelConfiguration {
//         ModelConfiguration()
//     }

//     /// The default app store preview configuration.
//     static var previewConfig: ModelConfiguration {
//         ModelConfiguration(
//             isStoredInMemoryOnly: true
//         )
//     }

//     /// Initialize a new model container.
//     static func createContainer(
//         configurations: any DataStoreConfiguration...
//     ) throws -> ModelContainer {
//         do {
//             return try ModelContainer(
//                 for: Self.schema, configurations: configurations
//             )
//         } catch {
//             throw DatabaseError.InitializationError(
//                 "Failed to create app model container.", error
//             )
//         }
//     }
// }

@main struct HealthTrackerApp: App {
    internal let logger = AppLogger.new(for: Self.self)

    init() {
        // self.
        // _ = try! AppDataStore.initializeContainer(
        //     configurations: AppDataStore.defaultConfig,
        //     HealthKitStoreConfiguration()
        // )

        // let settings = try! AppSettings.singleton(in: AppDataStore.container.mainContext)
        // var calendar = Calendar.current
        // calendar.firstWeekday = settings.startOfWeek.rawValue
        // try! HealthKitService.enable()
        // self.logger.debug("App initialized.")
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
