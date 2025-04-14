import Foundation
import SwiftData
import SwiftUI

/// A property wrapper to fetch a singleton model. If multiple models are
/// found, the first one is returned.
@propertyWrapper
struct SingletonQuery<Model: PersistentModel>: DynamicProperty {
    @Query var models: [Model]
    var wrappedValue: Model? { self.models.first }

    init(_ query: Query<Model, [Model]>) { self._models = query }

    @MainActor init(
        _ descriptor: FetchDescriptor<Model> = .init(),
        animation: Animation = .default,
    ) {
        var descriptor = descriptor
        descriptor.fetchLimit = 1
        self._models = Query(descriptor, animation: animation)
    }

    @MainActor init(
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

    @MainActor init(
        _ id: Model.ID?,
        sortBy: [SortDescriptor<Model>] = [
            SortDescriptor(\.persistentModelID)
        ],
        animation: Animation = .default,
    ) where Model: Singleton {
        guard let id else {
            self.init(sortBy: sortBy, animation: animation)
            return
        }

        self.init(
            #Predicate { $0.id == id },
            sortBy: sortBy, animation: animation
        )
    }
}
extension Query { typealias Singleton = SingletonQuery }
