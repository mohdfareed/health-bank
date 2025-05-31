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

    @State private var reset = false

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
                switch record {
                case let weight as Weight:
                    UniversalRecordRow(record: weight) {
                        Text("Weight Detail View - TODO")
                    }
                case let calorie as DietaryCalorie:
                    UniversalRecordRow(record: calorie) {
                        Text("Calorie Detail View - TODO")
                    }
                case let active as ActiveEnergy:
                    UniversalRecordRow(record: active) {
                        Text("Active Energy Detail View - TODO")
                    }
                case let resting as RestingEnergy:
                    UniversalRecordRow(record: resting) {
                        Text("Resting Energy Detail View - TODO")
                    }
                default:
                    EmptyView()
                }
            }
        }
        .refreshable {
            self.reset = false
            await $dietaryCalories.refresh()
            await $restingCalories.refresh()
            await $activities.refresh()
            await $weights.refresh()
        }
    }
}
