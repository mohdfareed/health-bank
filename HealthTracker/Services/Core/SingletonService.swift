import Foundation
import SwiftData
import SwiftUI

// MARK: `SwiftUI` Integration
// ============================================================================

/// A property wrapper to fetch a singleton model. If multiple models are
/// found, the first instance is used.
@MainActor @propertyWrapper
struct SingletonQuery<Model: PersistentModel>: DynamicProperty {
    @Query private var models: [Model]
    var wrappedValue: Model? { self.models.first }

    init(_ query: Query<Model, [Model]>) { self._models = query }

    init(  // default to using first model in store
        _ descriptor: FetchDescriptor<Model> = .init(),
        animation: Animation = .default,
    ) {
        var descriptor = descriptor
        descriptor.fetchLimit = 1
        self._models = Query(descriptor, animation: animation)
    }

    init(  // default to assuming unique zero ID implementation
        _ id: Model.ID = UUID.zero,
        sortBy: [SortDescriptor<Model>] = [
            SortDescriptor(\.persistentModelID)
        ],
        animation: Animation = .default,
    ) where Model: Singleton {
        self.init(
            .init(predicate: #Predicate { $0.id == id }, sortBy: sortBy),
            animation: animation
        )
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
