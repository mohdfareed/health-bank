import Foundation
import OSLog
import SwiftData

/// The supported sources of data.
enum DataSource: Codable {
    case HealthKit
    case CoreData

    /// All sources.
    static var all: [DataSource] {
        [.HealthKit, .CoreData]
    }
}

/// A data model. All models which interact with the app's data store
/// conform to this protocol.
protocol DataModel: PersistentModel {
    /// The source of the data.
    var source: DataSource { get }
}

// A historical data model.
protocol HistoricalDataModel: DataModel {
    /// The date the record was created.
    var date: Date { get }
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
struct ValuePoint<X, Y>: DataPoint {
    var x: X
    var y: Y
}

// MARK: Data Store

/// An application data store accessible from SwiftUI.
/// This type is used by the `DataContainer` to provide a SwiftData
/// in-memory buffer for the store.
protocol Store<Model> {
    associatedtype Model: DataModel

    /// The data sources supported by the store.
    /// The store will only handle data from one of these sources and
    /// data conforming to the `DataModel` protocol.
    var sources: [DataSource] { get }

    func save(_ model: Model) throws
    /// Deletes a record.
    func delete(_ model: Model) throws

    /// Fetches records matching a predicate.
    func fetch<M>(_ descriptor: FetchDescriptor<M>) throws -> [M]
    where M == Model
}
