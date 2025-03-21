import SwiftData
import SwiftUI

// MARK: Data Store

/// The default application data store.
struct AppDataStore {
    private static let config = ModelConfiguration(
        schema: Schema(
            [AppSettings.self, AppState.self]
        ))

    private static let previewConfig = ModelConfiguration(
        isStoredInMemoryOnly: true
    )

    /// Create the default app model container.
    static func container(
        _ schema: Schema, configurations: any DataStoreConfiguration...
    ) throws -> ModelContainer {
        return try createContainer(schema, [config] + configurations)
    }

    /// Create the app's default model container.
    static func previewContainer(
        _ schema: Schema, configurations: any DataStoreConfiguration...
    ) throws -> ModelContainer {
        return try createContainer(schema, [previewConfig] + configurations)
    }

    private static func createContainer(
        _ schema: Schema, _ configurations: [any DataStoreConfiguration]
    ) throws -> ModelContainer {
        do {
            return try ModelContainer(
                for: schema, configurations: configurations
            )
        } catch {
            throw DatabaseError.InitializationError(
                "Failed to create 'ModelContainer'", error
            )
        }
    }
}

// MARK: Singleton

/// Persist the model as a singleton.
/// Allows the use the the `@FetchSingleton` SwiftUI wrapper.
protocol SingletonModel: PersistentModel, CustomStringConvertible {
    /// The singleton's default constructor.
    static var singletonFactory: () -> Self { get }
}

extension SingletonModel {
    internal static var singletonID: Self.ID {
        return singletonFactory().id
    }
    var description: String {
        return String(describing: self)
    }
}

@propertyWrapper
struct FetchSingleton<Model: SingletonModel> {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Model> { $0.id == Model.singletonID })
    private var models: [Model]
    internal let logger = AppLogger.new(for: Model.self)

    var wrappedValue: Model {
        if let existingModel = models.first {
            return existingModel
        }

        let newModel = Model.singletonFactory()
        self.logger.info("Creating default '\(Model.self)' model: \(newModel)")
        context.insert(newModel)
        return newModel
    }
}
