import Foundation
import SwiftData
import SwiftUI

// MARK: Macros Breakdown
// ============================================================================

extension DietaryEnergy {
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
