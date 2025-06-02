import SwiftData
import SwiftUI

// MARK: Categories Data
// ============================================================================

/// Projection for RecordsQuery providing aggregated loading states and pagination controls
@MainActor
struct RecordsQueryProjection {
    let isRefreshing: Bool
    let isLoading: Bool
    let refresh: () async -> Void
    let load: () async -> Void
}

@MainActor @propertyWrapper struct RecordsQuery: DynamicProperty {
    @DataQuery var dietaryCalories: [DietaryCalorie]
    @DataQuery var restingCalories: [RestingEnergy]
    @DataQuery var activities: [ActiveEnergy]
    @DataQuery var weights: [Weight]

    init(
        from start: Date? = nil, to end: Date? = nil,
        pageSize: Int = 50
    ) {
        _dietaryCalories = .init(
            DietaryQuery(), from: start, to: end, pageSize: pageSize
        )
        _restingCalories = .init(
            RestingQuery(), from: start, to: end, pageSize: pageSize
        )
        _activities = .init(
            ActivityQuery(), from: start, to: end, pageSize: pageSize
        )
        _weights = .init(
            WeightQuery(), from: start, to: end, pageSize: pageSize
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

    var projectedValue: RecordsQueryProjection {
        .init(
            isRefreshing: $dietaryCalories.isRefreshing
                || $restingCalories.isRefreshing
                || $activities.isRefreshing
                || $weights.isRefreshing,
            isLoading: $dietaryCalories.isLoading
                || $restingCalories.isLoading
                || $activities.isLoading
                || $weights.isLoading,
            refresh: refresh,
            load: loadNextPage
        )
    }

    func refresh() async {
        await $dietaryCalories.refresh()
        await $restingCalories.refresh()
        await $activities.refresh()
        await $weights.refresh()
    }

    func loadNextPage() async {
        await $dietaryCalories.loadNext()
        await $restingCalories.loadNext()
        await $activities.loadNext()
        await $weights.loadNext()
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
