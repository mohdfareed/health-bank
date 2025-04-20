import Foundation
import SwiftData
import SwiftUI

// MARK: Queries
// ============================================================================

extension RemoteQuery {
    static func burned(
        from: Date = Date().floored(to: .day), to: Date = Date(),
        min: Double = 0, max: Double = .infinity
    ) -> CalorieQuery<Model> where Model: BurnedCalorie {
        .init(from: from, to: to, min: min, max: max)
    }

    static func consumed(
        from: Date = Date().floored(to: .day), to: Date = Date(),
        min: Double = 0, max: Double = .infinity
    ) -> CalorieQuery<Model> where Model: DietaryCalorie {
        .init(from: from, to: to, min: min, max: max)
    }

    static func macros(
        calories: CalorieQuery<Model>,
    ) -> MacrosQuery<Model> where Model: DietaryCalorie {
        .init(calories: calories)
    }
}

// MARK: Local Queries
// ============================================================================

extension CalorieQuery: CoreQuery where C: PersistentModel {
    var descriptor: FetchDescriptor<C> {
        let (from, to, min, max) = (self.from, self.to, self.min, self.max)
        return FetchDescriptor<C>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to
                    && $0.calories > min && $0.calories < max
            },
            sortBy: [SortDescriptor(\.date)]
        )
    }
}

extension MacrosQuery: CoreQuery where C: PersistentModel {
    var descriptor: FetchDescriptor<C> {
        let (from, to) = (self.calories.from, self.calories.to)
        let (min, max) = (self.calories.min, self.calories.max)
        return FetchDescriptor<C>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to && $0.macros != nil
                    && $0.calories > min && $0.calories < max
            },
            sortBy: [SortDescriptor(\.date)]
        )
    }
}

// MARK: Macros Extensions
// ============================================================================

@MainActor
extension Binding<CalorieMacros?> {
    var proteinValue: Binding<Double> {
        self.defaulted(to: .init()).protein.defaulted(to: 0)
    }
    var fatValue: Binding<Double> {
        self.defaulted(to: .init()).fat.defaulted(to: 0)
    }
    var carbsValue: Binding<Double> {
        self.defaulted(to: .init()).carbs.defaulted(to: 0)
    }
}

// MARK: Macros Breakdown
// ============================================================================

extension DietaryCalorie {
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
