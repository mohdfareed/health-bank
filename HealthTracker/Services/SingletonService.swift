import Foundation
import SwiftData
import SwiftUI

/// Persist the model as a singleton.
/// Allows the use the the `@SingletonQuery` SwiftUI wrapper.
/// The singleton is designed to wrap a single record in the database. The
/// singleton record's ID is stored in the UserDefaults.
/// Backups can be created by saving new instances of the model. A backup
/// can be restored by settings the singleton's wrapped value to the backup.
protocol SingletonModel: PersistentModel { init() }

/// A property wrapper to fetch a singleton model.
/// The model is fetched from the context and created if it doesn't exist.
/// The singleton is determined by the respective UserDefaults key.
/// The instance can be overwritten to update the stored singleton.
@MainActor @propertyWrapper
struct SingletonQuery<Model: SingletonModel>: DynamicProperty
where Model.ID == PersistentIdentifier {
    @Environment(\.modelContext) private var context
    @AppStorage("\(Model.self).singletonID") private var id: Model.ID?
    @Query private var models: [Model]

    init() {
        var descriptor = FetchDescriptor<Model>(
            predicate: #Predicate { instance in
                instance.id == self.id
            }
        )
        descriptor.fetchLimit = 1
        self._models = Query(descriptor)
    }

    var wrappedValue: Model {
        get {
            if let existingModel = models.first {
                return existingModel
            }

            let newValue = Model()
            context.insert(newValue)
            self.id = newValue.id
            return newValue
        }
        nonmutating set {
            context.insert(newValue)
            if let existingModel = models.first {
                context.delete(existingModel)
            }
            self.id = newValue.id
        }
    }

    var projectedValue: Binding<Model> {
        Binding(get: { self.wrappedValue }, set: { self.wrappedValue = $0 })
    }
}

extension Query {
    typealias Singleton = SingletonQuery
}
