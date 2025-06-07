import Foundation
import SwiftData

// MARK: Supported Types
// ============================================================================

/// The health data model types.
enum HealthDataModel: CaseIterable {
    case calorie
    case activity
    case weight

    var dataType: any HealthData.Type {
        switch self {
        case .calorie:
            return DietaryCalorie.self
        case .activity:
            return ActiveEnergy.self
        case .weight:
            return Weight.self
        }
    }

    static var allTypes: [any HealthData.Type] {
        allCases.map { $0.dataType }
    }
}

// MARK: Interface
// ============================================================================

/// The health data source.
public enum DataSource: Codable, CaseIterable {
    case app
    case healthKit
    case other
}

/// Base protocol for all health data.
public protocol HealthData: Identifiable, Observable {
    /// The data's ID.
    var id: UUID { get }
    /// The data's source.
    var source: DataSource { get }
    /// When the data was recorded.
    var date: Date { get set }
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
    func save(store: HealthKitService) async throws
    /// Delete data from HealthKit.
    func delete(store: HealthKitService) async throws
    /// Update data in HealthKit.
    func update(store: HealthKitService) async throws
}
