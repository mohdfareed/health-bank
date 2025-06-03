import SwiftData
import SwiftUI

// MARK: Categories Data
// ============================================================================

@MainActor @propertyWrapper
struct RecordsQuery: DynamicProperty {
    @DataQuery var dietaryCalories: [DietaryCalorie]
    @DataQuery var restingCalories: [RestingEnergy]
    @DataQuery var activities: [ActiveEnergy]
    @DataQuery var weights: [Weight]

    init(
        from start: Date? = nil, to end: Date? = nil,
        pageSize: Int = 50
    ) {
        _dietaryCalories = .init(
            DietaryQuery(), from: start, to: end, limit: pageSize,
        )
        _restingCalories = .init(
            RestingQuery(), from: start, to: end, limit: pageSize,
        )
        _activities = .init(
            ActivityQuery(), from: start, to: end, limit: pageSize,
        )
        _weights = .init(
            WeightQuery(), from: start, to: end, limit: pageSize,
        )
    }

    var wrappedValue: [any HealthRecord] {
        var records = [any HealthRecord]()
        records.append(contentsOf: dietaryCalories)
        records.append(contentsOf: restingCalories)
        records.append(contentsOf: activities)
        records.append(contentsOf: weights)
        return records.sorted { $0.date > $1.date }
    }
    var projectedValue: Self { self }

    var isLoading: Bool {
        $dietaryCalories.isLoading
            || $restingCalories.isLoading
            || $activities.isLoading
            || $weights.isLoading
    }

    var hasMoreData: Bool {
        $dietaryCalories.hasMoreData
            || $restingCalories.hasMoreData
            || $activities.hasMoreData
            || $weights.hasMoreData
    }

    func reload() async {
        await $dietaryCalories.reload()
        await $restingCalories.reload()
        await $activities.reload()
        await $weights.reload()
    }

    func load() async {
        await $dietaryCalories.load()
        await $restingCalories.load()
        await $activities.load()
        await $weights.load()
    }
}

extension ModelContext {
    /// Erase all data in the context.
    func eraseAll() {
        do {
            try self.delete(model: DietaryCalorie.self)
            try self.delete(model: RestingEnergy.self)
            try self.delete(model: ActiveEnergy.self)
            try self.delete(model: Weight.self)
        } catch {
            print("Failed to erase all data: \(error)")
        }
    }
}
