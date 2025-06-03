import SwiftData
import SwiftUI

// MARK: Categories
// ============================================================================

enum HealthRecordCategory: String, CaseIterable {
    case dietary
    case active
    case resting
    case weight

    var icon: Image {
        switch self {
        case .dietary: return .dietaryCalorie
        case .resting: return .restingCalorie
        case .active: return .activeCalorie
        case .weight: return .weight
        }
    }

    var color: Color {
        switch self {
        case .dietary: return .dietaryCalorie
        case .resting: return .restingCalorie
        case .active: return .activeCalorie
        case .weight: return .weight
        }
    }

    func state<T: HealthRecord>() -> State<T> {
        switch self {
        case .dietary:
            return State<T>(initialValue: DietaryCalorie(0) as! T)
        case .resting:
            return State<T>(initialValue: RestingEnergy(0) as! T)
        case .active:
            return State<T>(initialValue: ActiveEnergy(0) as! T)
        case .weight:
            return State<T>(initialValue: Weight(0) as! T)
        }
    }

    func query<T: HealthRecord>() -> any HealthQuery<T> {
        switch self {
        case .dietary: return DietaryQuery() as! any HealthQuery<T>
        case .resting: return RestingQuery() as! any HealthQuery<T>
        case .active: return ActivityQuery() as! any HealthQuery<T>
        case .weight: return WeightQuery() as! any HealthQuery<T>
        }
    }

    func createRecord() -> any HealthRecord {
        switch self {
        case .dietary: return DietaryCalorie(0)
        case .resting: return RestingEnergy(0)
        case .active: return ActiveEnergy(0)
        case .weight: return Weight(0)
        }
    }
}

// MARK: Rows
// ============================================================================

extension HealthRecordCategory {
    @ViewBuilder @MainActor
    static func recordRow(_ record: any HealthRecord) -> some View {
        switch record {
        case let weight as Weight:
            RecordDefinition.weight.recordRow(weight)
        case let calorie as DietaryCalorie:
            RecordDefinition.dietary.recordRow(calorie)
        case let calorie as ActiveEnergy:
            RecordDefinition.active(
                workout: calorie.workout
            ).recordRow(calorie)
        case let calorie as RestingEnergy:
            RecordDefinition.resting.recordRow(calorie)
        default:
            let _ = AppLogger.new(for: record)
                .error("Unknown record type: \(type(of: record))")
            EmptyView()
        }
    }
}

// MARK: Sheets
// ============================================================================

extension HealthRecordCategory {
    @ViewBuilder @MainActor
    static func recordSheet(
        _ record: any HealthRecord
    ) -> some View {
        switch record {
        case let record as Weight:
            RecordForm("Log Weight", record: record) {
                FormDefinition.weight.content(record)
            }
        case let record as DietaryCalorie:
            RecordForm("Log Food", record: record) {
                FormDefinition.dietaryCalorie.content(record)
            }
        case let record as ActiveEnergy:
            RecordForm("Log Activity", record: record) {
                FormDefinition.activeEnergy.content(record)
            }
        case let record as RestingEnergy:
            RecordForm("Log Resting Energy", record: record) {
                FormDefinition.restingEnergy.content(record)
            }
        default:
            let _ = AppLogger.new(for: record)
                .error("Unknown record type: \(type(of: record))")
            EmptyView()
        }
    }
}
