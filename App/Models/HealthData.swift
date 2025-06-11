import Foundation
import SwiftData

// MARK: Supported Types
// ============================================================================

/// The health data model types.
enum HealthDataModel<T: HealthData>: CaseIterable, Identifiable {
    case calorie, weight
    var dataType: any HealthData.Type {
        switch self {
        case .calorie:
            return DietaryCalorie.self
        case .weight:
            return Weight.self
        }
    }

    var id: Self { self }
    static var allTypes: [any HealthData.Type] {
        allCases.map { $0.dataType }
    }
}

// MARK: Interface
// ============================================================================

/// The health data source.
public enum DataSource: Codable, CaseIterable, Equatable {
    case app, healthKit
    case other(String)

    static public var allCases: [DataSource] {
        return [
            .app, .healthKit,
            .other(String(localized: "unknown")),
        ]
    }
}

/// Base protocol for all health data.
public protocol HealthData: Identifiable, Observable {
    /// The data's ID.
    var id: UUID { get }
    /// The data's source.
    var source: DataSource { get }
    /// When the data was recorded.
    var date: Date { get set }
    /// Default initializer for creation defaults.
    init()
}

/// Base protocol for data queries.
@MainActor public protocol HealthQuery<Data> {
    /// The type of data this query returns.
    associatedtype Data: HealthData

    /// Fetch the data models from HealthKit.
    func fetch(
        from: Date, to: Date, limit: Int?,
        store: HealthKitService
    ) async -> [Data]

    /// Save data in HealthKit.
    func save(_ data: Data, store: HealthKitService) async throws
    /// Delete data from HealthKit.
    func delete(_ data: Data, store: HealthKitService) async throws
}
