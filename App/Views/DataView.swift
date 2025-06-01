import SwiftData
import SwiftUI

struct HealthDataView: View {
    @UnifiedQuery(DietaryQuery())
    var dietaryCalories: [DietaryCalorie]
    @UnifiedQuery(RestingQuery())
    var restingCalories: [RestingEnergy]
    @UnifiedQuery(ActivityQuery())
    var activities: [ActiveEnergy]
    @UnifiedQuery(WeightQuery())
    var weights: [Weight]

    private var allRecords: [any HealthRecord & PersistentModel] {
        var records = [any HealthRecord & PersistentModel]()
        records.append(contentsOf: dietaryCalories)
        records.append(contentsOf: restingCalories)
        records.append(contentsOf: activities)
        records.append(contentsOf: weights)
        return records.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            List(allRecords, id: \.id) { record in
                recordRow(record)
            }
            .navigationTitle("Health Records")
        }
        .refreshable {
            await $dietaryCalories.refresh()
            await $restingCalories.refresh()
            await $activities.refresh()
            await $weights.refresh()
        }
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
