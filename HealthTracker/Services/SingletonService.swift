import Foundation
import SwiftData
import SwiftUI

/// Persist the model as a singleton.
/// Allows the use the the `@SingletonQuery` SwiftUI wrapper.
/// The singleton is designed to wrap a single record in the database. The
/// singleton record's ID is stored in the `UserDefaults`.
/// Backups can be created by saving new instances of the model. A backup
/// can be restored by settings the singleton's wrapped value to the backup.
protocol SingletonModel: PersistentModel where ID == UUID {}

/// A property wrapper to fetch a singleton model.
/// The model is fetched from the context and created if it doesn't exist.
/// The singleton is determined by the respective `UserDefaults` key.
/// The instance can be overwritten to update the stored singleton.
@MainActor @propertyWrapper
struct SingletonQuery<Model: SingletonModel>: DynamicProperty {
    @Environment(\.modelContext) private var context
    @AppStorage("\(Self.self).singletonID") private var singletonID: Model.ID?
    @Query private var models: [Model]

    private let logger = AppLogger.new(for: Self.self)
    private let defaultSingleton: Model

    init(wrappedValue: Model) {
        self.defaultSingleton = wrappedValue
        var descriptor = FetchDescriptor<Model>(
            predicate: #Predicate { instance in
                instance.id == self.singletonID
            }
        )
        descriptor.fetchLimit = 1
        self._models = Query(descriptor)
    }

    var wrappedValue: Model {
        get {
            if let existingModel = self.models.first {
                return existingModel
            }
            return self.defaultSingleton
        }

        nonmutating set {
            if let existingModel = self.models.first {
                context.delete(existingModel)
            }  // delete the old singleton

            context.insert(newValue)
            self.singletonID = newValue.id
            logger.debug("Updated singleton: \(Model.self).")
        }
    }

    var projectedValue: Binding<Model> {
        Binding(get: { self.wrappedValue }, set: { self.wrappedValue = $0 })
    }
}

extension SingletonQuery where Model: ExpressibleByNilLiteral {
    init() {
        self.init(wrappedValue: nil)
    }

    var wrappedValue: Model? {
        get { models.first }

        nonmutating set {
            if let existingModel = models.first {
                context.delete(existingModel)
            }

            guard let newSingleton = newValue else {
                self.singletonID = nil
                logger.debug("Deleted singleton: \(Model.self).")
                return
            }

            context.insert(newSingleton)
            self.singletonID = newSingleton.id
            logger.debug("Updated singleton: \(Model.self).")
        }
    }
}

extension Query {
    typealias Singleton = SingletonQuery
}
