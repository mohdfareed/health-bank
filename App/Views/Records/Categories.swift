import SwiftData
import SwiftUI

// MARK: Categories
// ============================================================================

enum HealthRecordCategory: String, CaseIterable, Identifiable {
    var id: String {
        self.rawValue
    }

    case dietary
    case active
    case weight

    var icon: Image {
        switch self {
        case .dietary: return .dietaryCalorie
        case .active: return .activeCalorie
        case .weight: return .weight
        }
    }

    var color: Color {
        switch self {
        case .dietary: return .dietaryCalorie
        case .active: return .activeCalorie
        case .weight: return .weight
        }
    }

    func query<T: HealthData>() -> any HealthQuery<T> {
        switch self {
        case .dietary: return DietaryQuery() as! any HealthQuery<T>
        case .active: return ActivityQuery() as! any HealthQuery<T>
        case .weight: return WeightQuery() as! any HealthQuery<T>
        }
    }

    func record() -> any HealthData {
        switch self {
        case .dietary: return DietaryCalorie(0)
        case .active: return ActiveEnergy(0)
        case .weight: return Weight(0)
        }
    }
}

// MARK: Rows
// ============================================================================

extension HealthRecordCategory {
    @ViewBuilder @MainActor
    static func recordRow(_ record: any HealthData) -> some View {
        switch record {
        case let weight as Weight:
            RecordDefinition.weight.recordRow(weight)
        case let calorie as DietaryCalorie:
            RecordDefinition.dietary.recordRow(calorie)
        case let calorie as ActiveEnergy:
            RecordDefinition.active(
                workout: calorie.workout
            ).recordRow(calorie)
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
    @ViewBuilder @MainActor var recordSheet: some View {
        let record = record()
        switch record {
        case let record as Weight:
            RecordForm("Weight", creating: record) {
                FormDefinition.weight.content(record)
            }
        case let record as DietaryCalorie:
            RecordForm("Food", creating: record) {
                FormDefinition.dietaryCalorie.content(record)
            }
        case let record as ActiveEnergy:
            RecordForm("Activity", creating: record) {
                FormDefinition.activeEnergy.content(record)
            }
        default:
            let _ = AppLogger.new(for: record)
                .error("Unknown record type: \(type(of: record))")
            EmptyView()
        }
    }
}
