import Foundation
import SwiftData
import SwiftUI

/// A property wrapper to fetch a singleton model. If multiple models are
/// found, the first one is returned, ordered by the model's persistence ID.
/// The singleton criteria is defined by either the model's persistence ID,
/// the model's user-defined ID, or a custom predicate. A default initializer
/// is provided to fetch the first model of the specified type.
@MainActor @propertyWrapper
struct SingletonQuery<Model: PersistentModel>: DynamicProperty {
    @Query var models: [Model]
    var wrappedValue: Model? { self.models.first }

    init(_ query: Query<Model, [Model]>) { self._models = query }

    init(
        _ descriptor: FetchDescriptor<Model> = .init(),
        animation: Animation = .default,
    ) {
        var descriptor = descriptor
        descriptor.fetchLimit = 1
        self._models = Query(descriptor, animation: animation)
    }

    init(
        _ predicate: Predicate<Model>? = #Predicate { _ in true },
        sortBy: [SortDescriptor<Model>] = [
            SortDescriptor(\.persistentModelID)
        ],
        animation: Animation = .default,
    ) {
        let descriptor = FetchDescriptor<Model>(
            predicate: predicate, sortBy: sortBy
        )
        self.init(descriptor, animation: animation)
    }
}
extension Query { typealias Singleton = SingletonQuery }
