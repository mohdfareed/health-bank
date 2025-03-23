import Foundation
import SwiftData
import SwiftUI

/// Budget data model service.
struct DataService {
    internal let logger = AppLogger.new(for: DataService.self)
    private let context: ModelContext

    init(_ context: ModelContext) {
        self.context = context
        self.logger.debug("Data model service initialized.")
    }

    /// Create the fetch descriptor for data models.
    /// - Parameter predicate: The predicate to filter by.
    /// - Parameter sortBy: The sort order of the data.
    /// - Returns: The entries.
    func fetch<T: PersistentModel>(
        predicate: Predicate<T>? = nil,
        sortBy: [SortDescriptor<T>] = []
    ) throws -> [T] {
        let fetchRequest = FetchDescriptor<T>(
            predicate: predicate, sortBy: sortBy
        )

        self.logger.debug("Retrieving models: \(T.self)")
        let entries = try self.context.fetch(fetchRequest)
        return entries
    }

    /// Log a new data model.
    /// - Parameter model: The model to log.
    func create<T: PersistentModel & CustomStringConvertible>(_ model: T) {
        self.logger.debug("Creating model: \(model)")
        self.context.insert(model)
    }

    /// Remove a data model.
    /// - Parameter model: The model to remove.
    func remove<T: PersistentModel & CustomStringConvertible>(_ model: T) {
        self.logger.debug("Removing model: \(model)")
        self.context.delete(model)
    }

    /// Update a data model.
    /// - Parameter model: The model to update.
    func update<T: PersistentModel & CustomStringConvertible>(_ model: T) {
        self.logger.debug("Updating model: \(model)")
        if let existing = self.context.model(for: model.id) as? T {
            self.context.delete(existing)
        }
        self.context.insert(model)
    }
}

// MARK: Singleton

/// Persist the model as a singleton.
/// Allows the use the the `@FetchSingleton` SwiftUI wrapper.
/// The singleton is designed to wrap the first entry in the fetch request.
/// Backups can be created and loaded by changing the first entry in the
/// singleton's table.
protocol SingletonModel: PersistentModel, CustomStringConvertible { init() }

extension SingletonModel {
    var description: String {
        return String(describing: self)
    }

    /// Fetch the singleton model from the context.
    static func singleton(in context: ModelContext) throws -> Self {
        if let singleton = try! context.fetch(
            FetchDescriptor<Self>()
        ).first {
            return singleton
        }

        let logger = AppLogger.new(for: Self.self)
        let newSingleton = Self()
        logger.info("Creating default '\(Self.self)' model: \(newSingleton)")

        context.insert(newSingleton)
        return newSingleton
    }
}

@propertyWrapper
struct FetchSingleton<Model: SingletonModel> {
    internal let logger = AppLogger.new(for: Model.self)

    @Environment(\.modelContext) private var context
    @Query private var models: [Model]

    var wrappedValue: Model {
        if let existingModel = models.first {
            return existingModel
        }

        let newModel = Model()
        self.logger.info("Creating default '\(Model.self)' model: \(newModel)")
        context.insert(newModel)
        return newModel
    }
}
