import Foundation
import OSLog
import SwiftData

// MARK: Data Store

/// The supported sources of data.
enum DataSource: Codable {
    case HealthKit
    case CoreData
}

/// A protocol for data models that originate from a data source.
protocol DataResource: PersistentModel {
    /// The source of the data.
    var source: DataSource { get }
}

/// An application store that is the source of data.
protocol ResourceStore<SupportedModel> {
    /// The type of models the store supports.
    associatedtype SupportedModel: DataResource
    /// The source of the store's data.
    static var source: DataSource { get }

    /// Creates or updates a record in the store.
    func save(_ model: SupportedModel) throws
    /// Deletes a record from the store.
    func delete(_ model: SupportedModel) throws
    /// Fetches records matching a predicate. The fetched records are always
    /// only those sourced from the store.
    func fetch<M>(_ descriptor: FetchDescriptor<M>) throws -> [M]
    where M == SupportedModel
}

// MARK: Plotting

/// A data point made up of 2 data values. Allows 2D operations.
protocol DataPoint<X, Y> {
    associatedtype X
    associatedtype Y
    var x: X { get }
    var y: Y { get }
}

/// A data point default implementation.
struct GenericPoint<X, Y>: DataPoint {
    var x: X
    var y: Y
}
