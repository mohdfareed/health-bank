import SwiftData
import SwiftUI

// MARK: Categories Data
// ============================================================================

@MainActor @propertyWrapper struct RecordsQuery: DynamicProperty {
    @Environment(\.modelContext) private var context

    @UnifiedQuery(DietaryQuery())
    var dietaryCalories: [DietaryCalorie]
    @UnifiedQuery(RestingQuery())
    var restingCalories: [RestingEnergy]
    @UnifiedQuery(ActivityQuery())
    var activities: [ActiveEnergy]
    @UnifiedQuery(WeightQuery())
    var weights: [Weight]

    var wrappedValue: [any HealthRecord & PersistentModel] {
        var records = [any HealthRecord & PersistentModel]()
        records.append(contentsOf: dietaryCalories)
        records.append(contentsOf: restingCalories)
        records.append(contentsOf: activities)
        records.append(contentsOf: weights)
        return records.sorted { $0.date > $1.date }
    }
    var projectedValue: Self { self }

    func refresh() async {
        await $dietaryCalories.refresh()
        await $restingCalories.refresh()
        await $activities.refresh()
        await $weights.refresh()
    }

    @ViewBuilder func recordRow(_ record: any HealthRecord) -> some View {
        switch record {
        case let weight as Weight:
            RecordDefinition.weight.recordRow(weight)
        case let calorie as DietaryCalorie:
            RecordDefinition.dietary.recordRow(calorie)
        case let calorie as ActiveEnergy:
            RecordDefinition.active.recordRow(calorie)
        case let calorie as RestingEnergy:
            RecordDefinition.resting.recordRow(calorie)
        default:
            let _ = AppLogger.new(for: record)
                .error("Unknown record type: \(type(of: record))")
            EmptyView()
        }
    }
}

// MARK: Categories
// ============================================================================

enum HealthRecordCategory: String.LocalizationValue, CaseIterable {
    case dietary = "Dietary Calorie"
    case active = "Active Energy"
    case resting = "Resting Energy"
    case weight = "Weight"

    var record: any HealthRecord & PersistentModel {
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

// MARK: Sheets
// ============================================================================

extension HealthRecordCategory {
    @ViewBuilder @MainActor
    static func recordSheet(
        _ record: any HealthRecord & PersistentModel
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

// MARK: Menus
// ============================================================================

extension HealthRecordCategory {
    @MainActor
    static func addMenu(
        action: @escaping @MainActor (Self) -> Void
    ) -> some View {
        Menu {
            ForEach(Self.allCases, id: \.self) { category in
                Button(action: { action(category) }) {
                    Label {
                        Text(String(localized: category.rawValue))
                    } icon: {
                        category.icon
                    }
                }
            }
        } label: {
            Label("Add", systemImage: "plus.circle")
        }
    }

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
