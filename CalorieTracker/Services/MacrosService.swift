import Foundation

extension ConsumedCalories {
    /// The total calories from the macros.
    var calories: UInt? {
        guard let p = self.macros.protein, let f = self.macros.fat, let c = self.macros.carbs else {
            return nil
        }
        return UInt(((p + c) * 4) + (f * 9))
    }

    /// The amount of protein in grams from the calories.
    func calFat() -> Double? {
        guard let protein = self.macros.protein, let carbs = self.macros.carbs else {
            return nil
        }

        let proteinCalories = protein * 4
        let carbsCalories = carbs * 4
        return (Double(self.consumed) - proteinCalories - carbsCalories) / 9
    }

    /// The amount of fat in grams from the calories.
    func calcProtein() -> Double? {
        guard let fat = self.macros.fat, let carbs = self.macros.carbs else {
            return nil
        }

        let fatCalories = fat * 9
        let carbsCalories = carbs * 4
        return (Double(self.consumed) - fatCalories - carbsCalories) / 4
    }

    /// The amount of carbs in grams from the calories.
    func calcCarbs() -> Double? {
        guard let protein = self.macros.protein, let fat = self.macros.fat else {
            return nil
        }

        let proteinCalories = protein * 4
        let fatCalories = fat * 9
        return (Double(self.consumed) - proteinCalories - fatCalories) / 4
    }
}
