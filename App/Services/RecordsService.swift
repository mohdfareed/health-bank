import SwiftData
import SwiftUI

// MARK: Categories Data
// ============================================================================

@MainActor @propertyWrapper struct RecordsQuery: DynamicProperty {
    @Environment(\.modelContext) private var context

    @DataQuery var dietaryCalories: [DietaryCalorie]
    @DataQuery var restingCalories: [RestingEnergy]
    @DataQuery var activities: [ActiveEnergy]
    @DataQuery var weights: [Weight]

    init(
        from start: Date? = nil, to end: Date? = nil,
        count: Int? = nil
    ) {
        _dietaryCalories = .init(
            DietaryQuery(), from: start, to: end, limit: count
        )
        _restingCalories = .init(
            RestingQuery(), from: start, to: end, limit: count
        )
        _activities = .init(
            ActivityQuery(), from: start, to: end, limit: count
        )
        _weights = .init(
            WeightQuery(), from: start, to: end, limit: count
        )
    }

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
}
