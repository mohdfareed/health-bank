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
