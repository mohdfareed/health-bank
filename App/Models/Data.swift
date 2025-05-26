// DataProvider.swift
// Data provider protocols for accessing health data

import Combine
import Foundation

// MARK: - Data Models
// ============================================================================

/// The supported sources of data.
public enum DataSource: Codable, CaseIterable {
    case local, healthKit

    #if DEBUG
        case simulation
    #endif
}

/// Base protocol for all health data records.
public protocol DataRecord {
    /// When the data was recorded.
    var date: Date { get }
    /// Where the data originated from.
    var source: DataSource { get }
}

// MARK: - Data Providers
// ============================================================================

/// Protocol for data providers that can fetch health records.
public protocol DataProvider {
    /// Fetches records of a specified type within a time range.
    /// - Parameters:
    ///   - type: The type of records to fetch
    ///   - timeRange: Optional time range to filter by
    ///   - limit: Maximum number of records to fetch
    ///   - offset: Number of records to skip
    /// - Returns: A publisher that emits the records
    func fetch<T: DataRecord>(
        _ type: T.Type,
        in timeRange: ClosedRange<Date>?,
        limit: Int?, offset: Int?
    ) -> AnyPublisher<[T], Error>

    /// Stores a record.
    /// - Parameter record: The record to store
    /// - Returns: A publisher that completes when the operation is done
    func store<T: DataRecord>(_ record: T) -> AnyPublisher<Void, Error>

    /// Deletes a record.
    /// - Parameter record: The record to delete
    /// - Returns: A publisher that completes when the operation is done
    func delete<T: DataRecord>(_ record: T) -> AnyPublisher<Void, Error>
}
