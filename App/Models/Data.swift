// DataProvider.swift
// Data provider protocols for accessing health data

import Foundation

// MARK: - Data Models
// ============================================================================

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
    /// - Returns: An array of matching records.
    /// - Throws: An error if fetching fails.
    func fetch<T: DataRecord>(
        _ type: T.Type,
        in timeRange: ClosedRange<Date>?,
        limit: Int?, offset: Int?
    ) async throws -> [T]

    /// Stores a record.
    /// - Parameter record: The record to store
    /// - Throws: An error if storing fails.
    func store<T: DataRecord>(_ record: T) async throws

    /// Deletes a record.
    /// - Parameter record: The record to delete
    /// - Throws: An error if deleting fails.
    func delete<T: DataRecord>(_ record: T) async throws
}
