import Foundation
import SwiftData

// MARK: Calories Consumed
// ============================================================================

extension CalorieConsumed {
    // TODO: Test localized unit (imperial). Convert to `.asProvided` if
    //       not a domain-specific unit.
    static var macrosUnit: UnitDefinition<UnitMass> { .init(unit: .grams) }
    static var calorieUnit: UnitDefinition<UnitEnergy> { .init(usage: .food) }
}

extension CalorieConsumed: RemoteRecord {
    typealias Model = Query
    struct Query: RemoteQuery {
        typealias Model = CalorieConsumed
        /// The minimum date.
        let from: Date = Date().floored(to: .day)
        /// The maximum date.
        let to: Date = Date()
        /// Whether to include only records with macros.
        let macros: Bool = false
    }
}

extension CalorieConsumed.Query: CoreQuery {
    var descriptor: FetchDescriptor<CalorieConsumed> {
        let (from, to, macros) = (self.from, self.to, self.macros)
        return FetchDescriptor<CalorieConsumed>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to
                    // macros NOT required or macros exist
                    && (!macros || $0.macros != nil)
            },
            sortBy: [SortDescriptor(\.date)]
        )
    }
}

// MARK: Calorie Burned
// ============================================================================

extension CalorieBurned {
    static var durationUnit: UnitDefinition<UnitDuration> { .init() }
    static var calorieUnit: UnitDefinition<UnitEnergy> {
        .init(usage: .workout)
    }
}

extension CalorieBurned: RemoteRecord {
    typealias Model = Query
    struct Query: RemoteQuery {
        typealias Model = CalorieBurned
        /// The minimum date.
        let from: Date
        /// The maximum date.
        let to: Date
        /// The minimum activity duration.
        let duration: TimeInterval
    }
}

extension CalorieBurned.Query: CoreQuery {
    var descriptor: FetchDescriptor<CalorieBurned> {
        let (from, to, duration) = (self.from, self.to, self.duration)
        return FetchDescriptor<CalorieBurned>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to
                    && $0.duration >= duration
            },
            sortBy: [SortDescriptor(\.date)]
        )
    }
}

// MARK: Calorie Breakdown
// ============================================================================

extension CalorieConsumed {
    /// The total calories from the macros.
    func calcCalories() -> Double? {
        guard
            let p = self.macros?.protein,
            let f = self.macros?.fat,
            let c = self.macros?.carbs
        else { return nil }
        return ((p + c) * 4) + (f * 9)
    }

    /// The amount of protein in grams from the calories.
    func calFat() -> Double? {
        guard
            let protein = self.macros?.protein,
            let carbs = self.macros?.carbs
        else { return nil }

        let proteinCalories = protein * 4
        let carbsCalories = carbs * 4
        return Double(self.calories - proteinCalories - carbsCalories) / 9
    }

    /// The amount of fat in grams from the calories.
    func calcProtein() -> Double? {
        guard
            let fat = self.macros?.fat,
            let carbs = self.macros?.carbs
        else { return nil }

        let fatCalories = fat * 9
        let carbsCalories = carbs * 4
        return Double(self.calories - fatCalories - carbsCalories) / 4
    }

    /// The amount of carbs in grams from the calories.
    func calcCarbs() -> Double? {
        guard
            let protein = self.macros?.protein,
            let fat = self.macros?.fat
        else { return nil }

        let proteinCalories = protein * 4
        let fatCalories = fat * 9
        return Double(self.calories - proteinCalories - fatCalories) / 4
    }
}
