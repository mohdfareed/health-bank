import SwiftData

/// The default application data store.
struct AppDataStore {
    private static var sharedContainer: ModelContainer?
    private static let schema = Schema([
        AppSettings.self,
        AppState.self,
        // Date models
        ConsumedCalories.self,
        BurnedCalories.self,
    ])

    /// The default app store configuration.
    static let defaultConfig = ModelConfiguration(
        schema: Schema(
            [AppSettings.self, AppState.self]
        ))

    /// The default app store preview configuration.
    static let previewConfig = ModelConfiguration(
        isStoredInMemoryOnly: true
    )

    /// The shared app data store model container.
    static var container: ModelContainer {
        if let container = sharedContainer {
            return container
        }
        fatalError("AppDataStore container not initialized.")
    }

    /// Initialize a new model container.
    static func initializeContainer(
        configurations: any DataStoreConfiguration...
    ) throws -> ModelContainer {
        do {
            Self.sharedContainer = try ModelContainer(
                for: Self.schema, configurations: configurations
            )
        } catch {
            throw DatabaseError.InitializationError(
                "Failed to create 'ModelContainer'", error
            )
        }
        return Self.sharedContainer!
    }
}
