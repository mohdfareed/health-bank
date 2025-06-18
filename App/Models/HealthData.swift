import Foundation
import SwiftData

// MARK: Supported Types
// ============================================================================

/// The health data model types.
enum HealthDataModel: CaseIterable, Identifiable {
    case calorie, weight

    /// The data model's type.
    var dataType: any HealthData.Type {
        switch self {
        case .calorie:
            return DietaryCalorie.self
        case .weight:
            return Weight.self
        }
    }

    /// Determine the data model from a data instance
    static func from(_ data: any HealthData) -> HealthDataModel {
        switch data {
        case is DietaryCalorie:
            return .calorie
        case is Weight:
            return .weight
        default:
            fatalError("Unknown health data type: \(type(of: data))")
        }
    }
}

// MARK: Interface
// ============================================================================

/// The health data source.
public enum DataSource: Codable, CaseIterable, Equatable, Sendable {
    case app, healthKit, shortcuts, foodNoms
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
