import SwiftData
import SwiftUI

// MARK: Singleton
// ============================================================================

/// A property wrapper to fetch a singleton model. If multiple models are
/// found, the first instance is used.
@MainActor @propertyWrapper
struct SingletonQuery<Model: Singleton>: DynamicProperty {
    @Environment(\.modelContext) private var context: ModelContext
    @Query private var models: [Model]
    private let factory: () -> Model

    var wrappedValue: Model {
        if let model = self.models.first { return model }
        let model = self.factory()
        self.context.insert(model)

        do { try self.context.save() } catch {
            AppLogger.new(for: Model.self).error(
                "Failed to save singleton model: \(error)"
            )
        }
        return model
    }
    var projectedValue: Bindable<Model> { .init(self.wrappedValue) }
}
extension Query { typealias Singleton = SingletonQuery }

extension Singleton {
    init(id: ID = UUID.zero) {
        self.init()
        self.id = id
    }
}

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
        _ id: Model.ID = UUID.zero,  // assume unique zero id
        sortBy: [SortDescriptor<Model>] = [
            SortDescriptor(\.persistentModelID)
        ],  // sort in case of non-unique id
        animation: Animation = .default,
    ) where Model: Singleton {
        var descriptor = FetchDescriptor(
            predicate: #Predicate { $0.id == id }, sortBy: sortBy,
        )
        descriptor.fetchLimit = 1  // singleton
        self.init(descriptor, factory: { Model(id: id) }, animation: animation)
    }
}
