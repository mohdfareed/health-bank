import Foundation
import SwiftData

// MARK: Calories Consumed
// ============================================================================

extension ConsumedCalorie {
    static var macrosUnit: UnitDefinition<UnitMass> { .init(unit: .grams) }
    static var calorieUnit: UnitDefinition<UnitEnergy> { .init(usage: .food) }
}  // units support

extension ConsumedCalorie: RemoteRecord {
    typealias Model = Query
    struct Query: RemoteQuery {
        typealias Model = ConsumedCalorie
        /// The minimum date.
        let from: Date = Date().floored(to: .day)
        /// The maximum date.
        let to: Date = Date()
        /// Whether to include only records with macros.
        let macros: Bool = false
    }
}  // remote query support

extension ConsumedCalorie.Query: CoreQuery {
    var descriptor: FetchDescriptor<ConsumedCalorie> {
        let (from, to, macros) = (self.from, self.to, self.macros)
        return FetchDescriptor<ConsumedCalorie>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to
                    // macros NOT required or macros exist
                    && (!macros || $0.macros != nil)
            },
            sortBy: [SortDescriptor(\.date)]
        )
    }
}  // swift data support

// MARK: Calorie Burned
// ============================================================================

extension BurnedCalorie {
    static var durationUnit: UnitDefinition<UnitDuration> { .init() }
    static var calorieUnit: UnitDefinition<UnitEnergy> {
        .init(usage: .workout)
    }
}

extension BurnedCalorie: RemoteRecord {
    typealias Model = Query
    struct Query: RemoteQuery {
        typealias Model = BurnedCalorie
        /// The minimum date.
        let from: Date
        /// The maximum date.
        let to: Date
        /// The minimum activity duration.
        let duration: TimeInterval
    }
}

extension BurnedCalorie.Query: CoreQuery {
    var descriptor: FetchDescriptor<BurnedCalorie> {
        let (from, to, duration) = (self.from, self.to, self.duration)
        return FetchDescriptor<BurnedCalorie>(
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

extension ConsumedCalorie {
    /// The amount of calories calculated from the macros.
    func calculatedCalories() -> Double? {
        guard
            let p = self.macros?.protein,
            let f = self.macros?.fat,
            let c = self.macros?.carbs
        else { return nil }
        return ((p + c) * 4) + (f * 9)
    }

    /// The amount of protein calculated from the calories, carbs, and fat.
    func calculatedProtein() -> Double? {
        guard
            let fat = self.macros?.fat,
            let carbs = self.macros?.carbs
        else { return nil }

        let fatCalories = fat * 9
        let carbsCalories = carbs * 4
        return Double(self.calories - fatCalories - carbsCalories) / 4
    }

    /// The amount of carbs calculated from the calories, protein, and fat.
    func calculatedCarbs() -> Double? {
        guard
            let protein = self.macros?.protein,
            let fat = self.macros?.fat
        else { return nil }

        let proteinCalories = protein * 4
        let fatCalories = fat * 9
        return Double(self.calories - proteinCalories - fatCalories) / 4
    }

    /// The amount of fat calculated from the calories, protein, and carbs.
    func calculatedFat() -> Double? {
        guard
            let protein = self.macros?.protein,
            let carbs = self.macros?.carbs
        else { return nil }

        let proteinCalories = protein * 4
        let carbsCalories = carbs * 4
        return Double(self.calories - proteinCalories - carbsCalories) / 9
    }
}
