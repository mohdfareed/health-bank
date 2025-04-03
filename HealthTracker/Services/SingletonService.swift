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
    private let logger = AppLogger.new(for: Self.self)
    @Query var models: [Model]
    var wrappedValue: Model? { return self.models.first }

    init(query: Query<Model, [Model]>? = nil) {
        self._models = Query(
            filter: #Predicate { _ in true },
            sort: \.persistentModelID, order: .forward
        )
    }

    init(_ id: PersistentIdentifier?) {
        let filter =
            id == nil
            ? #Predicate<Model> { _ in false }
            : #Predicate { $0.persistentModelID == id! }
        self._models = Query(
            filter: filter, sort: \.persistentModelID, order: .forward
        )
    }
}
extension Query { typealias Singleton = SingletonQuery }
