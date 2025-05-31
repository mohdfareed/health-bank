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
                // NavigationLink(
                //     destination: RecordDetailView(record: record)
                // ) {
                //     DetailedRow
                // }
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
