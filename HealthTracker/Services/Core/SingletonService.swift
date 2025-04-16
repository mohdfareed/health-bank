import Foundation
import SwiftData
import SwiftUI

// MARK: `SwiftUI` Integration
// ============================================================================

/// A property wrapper to fetch a singleton model. If multiple models are
/// found, the first one is returned.
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

    init(
        _ id: Model.ID? = UUID.zero,
        sortBy: [SortDescriptor<Model>] = [
            SortDescriptor(\.persistentModelID)
        ],
        animation: Animation = .default,
    ) where Model: Singleton {
        if let id = id {
            self.init(
                #Predicate { $0.id == id },
                sortBy: sortBy, animation: animation
            )
        } else {
            let zero = UUID.zero
            self.init(
                #Predicate { $0.id == zero },
                sortBy: sortBy, animation: animation
            )
        }
    }
}
extension Query { typealias Singleton = SingletonQuery }

// MARK: Settings
// ============================================================================

// Support `UUID` in app storage.
extension UUID: SettingsValue, @retroactive RawRepresentable {
    public var rawValue: String { self.uuidString }
    public init?(rawValue: String) { self.init(uuidString: rawValue) }
}
