import Foundation

/// The supported sources of data.
public enum DataSource: Codable, CaseIterable, Hashable {
    case local, healthKit
}

/// Base protocol for all health data records.
public protocol DataRecord {
    /// When the data was recorded.
    var date: Date { get nonmutating set }
    /// Where the data originated from.
    var source: DataSource { get }
}

/// Base protocol for data queries.
public protocol DataQuery<Record> {
    /// The type of data record this query returns.
    associatedtype Record: DataRecord
    /// The local data query predicate.
    func predicate() -> Predicate<Record>
    /// The remote data query runner.
    func remote(store: HealthKitService) -> [Record]
}
