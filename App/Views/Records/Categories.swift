import SwiftData
import SwiftUI

// MARK: Categories
// ============================================================================

enum HealthRecordCategory: String.LocalizationValue, CaseIterable {
    case dietary = "Food"
    case active = "Activity"
    case resting = "Resting Energy"
    case weight = "Weight"

    var record: any HealthRecord {
        switch self {
        case .dietary: return DietaryCalorie(0)
        case .resting: return RestingEnergy(0)
        case .active: return ActiveEnergy(0)
        case .weight: return Weight(0)
        }
    }

    var icon: Image {
        switch self {
        case .dietary: return .dietaryCalorie
        case .resting: return .restingCalorie
        case .active: return .activeCalorie
        case .weight: return .weight
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

// MARK: Add Menu
// ============================================================================

extension HealthRecordCategory {
    @MainActor
    static func addMenu(
        action: @escaping @MainActor (any HealthRecord) -> Void
    ) -> some View {
        Menu {
            ForEach(Self.allCases, id: \.self) { category in
                Button(action: { action(category.record) }) {
                    Label {
                        Text(String(localized: category.rawValue))
                    } icon: {
                        category.icon
                    }
                }
            }
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
}

// MARK: Filter Menu
// ============================================================================

extension HealthRecordCategory {

    @ViewBuilder @MainActor
    static func filterMenu(_ selected: Binding<[Self]>) -> some View {
        Menu {
            ForEach(Self.allCases, id: \.self) { category in
                Toggle(
                    isOn: Binding(
                        get: { selected.wrappedValue.contains(category) },
                        set: {
                            if $0 {
                                selected.wrappedValue.append(category)
                            } else {
                                selected.wrappedValue.removeAll {
                                    $0 == category
                                }
                            }
                        }
                    )
                ) { Text(String(localized: category.rawValue)) }
            }

            Divider()
            Toggle(
                isOn: Binding(
                    get: { selected.isEmpty },
                    set: { if $0 { selected.wrappedValue = [] } }
                )
            ) { Text("All Records") }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
    }
}
