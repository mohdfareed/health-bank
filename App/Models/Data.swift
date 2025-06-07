import Foundation
import SwiftData

// MARK: Supported Types
// ============================================================================

/// The health data model types.
enum HealthDataModel: CaseIterable {
    case calorie
    case activity
    case weight

    var dataType: any HealthDate.Type {
        switch self {
        case .calorie:
            return DietaryCalorie.self
        case .activity:
            return ActiveEnergy.self
        case .weight:
            return Weight.self
        }
    }

    static var allTypes: [any HealthDate.Type] {
        allCases.map { $0.dataType }
    }
}

// MARK: Interface
// ============================================================================

/// Base protocol for all health data.
public protocol HealthDate: Identifiable, Observable {
    /// The data's ID.
    var id: UUID { get }
    /// Whether the health data was created by this app.
    var isInternal: Bool { get }
    /// When the data was recorded.
    var date: Date { get set }
}

/// Base protocol for data queries.
@MainActor public protocol HealthQuery<Data> {
    /// The type of data this query returns.
    associatedtype Data: HealthDate
    /// Fetch the data models from HealthKit.
    func fetch(
        from: Date, to: Date, limit: Int?,
        store: HealthKitService
    ) async -> [Data]
}
