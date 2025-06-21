import SwiftData
import SwiftUI

// MARK: Singleton Models
// ============================================================================

extension UserGoals {
    public static func predicate(id: UUID) -> Predicate<UserGoals> {
        let singletonID = id
        return #Predicate { $0.id == singletonID }
    }
}

// MARK: Singleton Query
// ============================================================================

/// A property wrapper to fetch a singleton model. If multiple models are
/// found, the first instance is used.
@MainActor @propertyWrapper
public struct SingletonQuery<Model: Singleton>: DynamicProperty {
    @Environment(\.modelContext) private var context: ModelContext
    @Query private var models: [Model]
    private let factory: () -> Model

    public var wrappedValue: Model {
        if let model = self.models.first { return model }
        let model = self.factory()
        self.context.insert(model)

        do {
            try self.context.save()
        } catch {
            AppLogger.new(for: Model.self).error(
                "Failed to save singleton model: \(error)"
            )
        }
        return model
    }
    public var projectedValue: Bindable<Model> { .init(self.wrappedValue) }
}
extension Query { public typealias Singleton = SingletonQuery }

// MARK: Initializers
// ============================================================================

extension SingletonQuery {
    public init(_ id: UUID = .zero, animation: Animation = .default)
    where Model: Singleton {
        var descriptor = FetchDescriptor<Model>(
            predicate: Model.predicate(id: id),
            sortBy: [.init(\.persistentModelID)],
        )
        descriptor.fetchLimit = 1  // singleton

        self._models = Query(descriptor, animation: animation)
        self.factory = { Model(id: id) }
    }
}
