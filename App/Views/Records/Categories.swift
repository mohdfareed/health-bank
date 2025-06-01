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
            let type = type(of: record)
            let _ = AppLogger.new(for: type.self)
                .error("Unknown record type: \(type)")
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

    var record: HealthRecord.Type {
        switch self {
        case .dietary: return DietaryCalorie.self
        case .resting: return RestingEnergy.self
        case .active: return ActiveEnergy.self
        case .weight: return Weight.self
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
    var recordSheet: some View {
        switch self.record {
        case is Weight.Type:
            let weight = Weight(0)
            RecordForm("Log Weight", record: weight) {
                FormDefinition.weight.content(weight)
            }
        case is DietaryCalorie.Type:
            let calorie = DietaryCalorie(0)
            RecordForm("Log Food", record: calorie) {
                FormDefinition.dietaryCalorie.content(calorie)
            }
        case is ActiveEnergy.Type:
            let calorie = ActiveEnergy(0)
            RecordForm("Log Activity", record: calorie) {
                FormDefinition.activeEnergy.content(calorie)
            }
        case is RestingEnergy.Type:
            let calorie = RestingEnergy(0)
            RecordForm("Log Resting Energy", record: calorie) {
                FormDefinition.restingEnergy.content(calorie)
            }
        default:
            let _ = AppLogger.new(for: self.record.self)
                .error("Unknown record type: \(self.record)")
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
            Label("Add Record", systemImage: "plus")
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
