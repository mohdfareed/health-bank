import SwiftData
import SwiftUI

// MARK: Singleton Models
// ============================================================================

extension Singleton {
    init(id: UUID = UUID.zero) {
        self.init()
        self.singletonID = id
    }
}

extension UserGoals {
    static func predicate(id: UUID) -> Predicate<UserGoals> {
        let singletonID = id
        return #Predicate { $0.singletonID == singletonID }
    }
}

// MARK: Singleton Query
// ============================================================================

/// A property wrapper to fetch a singleton model. If multiple models are
/// found, the first instance is used.
@MainActor @propertyWrapper
struct SingletonQuery<Model: Singleton & PersistentModel>: DynamicProperty {
    @Environment(\.modelContext) private var context: ModelContext
    @Query private var models: [Model]
    private let factory: () -> Model

    var wrappedValue: Model {
        if let model = self.models.first { return model }
        let model = self.factory()
        self.context.insert(model)
        return model
    }
    var projectedValue: Bindable<Model> { .init(self.wrappedValue) }
}
extension Query { typealias Singleton = SingletonQuery }

// MARK: Queries
// ============================================================================

extension SingletonQuery {
    init(_ query: Query<Model, [Model]>, factory: @escaping () -> Model) {
        self._models = query
        self.factory = factory
    }

    init(
        _ descriptor: FetchDescriptor<Model>, factory: @escaping () -> Model,
        animation: Animation = .default,
    ) {
        self._models = Query(descriptor, animation: animation)
        self.factory = factory
    }

    init(
        _ id: UUID,
        sortBy: [SortDescriptor<Model>] = [.init(\.persistentModelID)],
        animation: Animation = .default,
    ) where Model: Singleton {
        let singletonID = id
        var descriptor = FetchDescriptor<Model>(
            predicate: Model.predicate(id: singletonID),
            sortBy: sortBy,
        )
        descriptor.fetchLimit = 1  // singleton
        self.init(descriptor, factory: { Model(id: id) }, animation: animation)
    }

    init(animation: Animation = .default) where Model: Singleton {
        self.init(UUID.zero, animation: animation)
    }
}
