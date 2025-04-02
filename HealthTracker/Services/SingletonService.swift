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

    var wrappedValue: Model? {
        if self.models.count > 1 {
            logger.warning(
                "Found (\(self.models.count)) models for type \(Model.self)."
            )
        }
        return self.models.first
    }

    init(_ id: PersistentIdentifier?) {
        guard let id = id else {
            self._models = Query(
                filter: #Predicate { _ in false },
                sort: \.persistentModelID, order: .forward
            )
            return
        }
        self._models = Query(
            filter: #Predicate { $0.persistentModelID == id },
            sort: \.persistentModelID, order: .forward
        )
    }
}
extension Query { typealias Singleton = SingletonQuery }
