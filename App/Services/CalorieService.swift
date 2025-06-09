import Foundation

// MARK: Budgets and Goals
// ============================================================================

extension UserGoals {
    /// The calories daily goal.
    var calorieGoal: DietaryCalorie {
        get {
            .init(self.calories ?? 0, macros: self.macros, date: self.date)
        }
        set {
            self.date = newValue.date
            self.calories = newValue.calories
            self.macros = newValue.macros
        }
    }
}

// MARK: Macro Calculations
// ============================================================================

extension DietaryCalorie {
    /// The amount of calories calculated from the macros or alcohol content.
    func calculatedCalories() -> Double? {
        guard
            let p = self.macros?.protein,
            let f = self.macros?.fat,
            let c = self.macros?.carbs,
            let a = self.alcohol
        else { return nil }
        return ((p + c) * 4) + (f * 9) + (a * 98)
    }

    /// The amount of protein calculated from the calories, carbs, and fat.
    func calculatedProtein() -> Double? {
        guard
            let fat = self.macros?.fat,
            let carbs = self.macros?.carbs,
            let alcohol = self.alcohol
        else { return nil }

        let fatCalories = fat * 9
        let carbsCalories = carbs * 4
        let alcoholCalories = alcohol * 98

        let macros = fatCalories + carbsCalories + alcoholCalories
        return Double(self.calories - macros) / 4
    }

    /// The amount of carbs calculated from the calories, protein, and fat.
    func calculatedCarbs() -> Double? {
        guard
            let protein = self.macros?.protein,
            let fat = self.macros?.fat,
            let alcohol = self.alcohol
        else { return nil }

        let proteinCalories = protein * 4
        let fatCalories = fat * 9
        let alcoholCalories = alcohol * 98

        let macros = proteinCalories + fatCalories + alcoholCalories
        return Double(self.calories - macros) / 4
    }

    /// The amount of fat calculated from the calories, protein, and carbs.
    func calculatedFat() -> Double? {
        guard
            let protein = self.macros?.protein,
            let carbs = self.macros?.carbs,
            let alcohol = self.alcohol
        else { return nil }

        let proteinCalories = protein * 4
        let carbsCalories = carbs * 4
        let alcoholCalories = alcohol * 98

        let macros = proteinCalories + carbsCalories + alcoholCalories
        return Double(self.calories - macros) / 9
    }

    /// The amount of alcohol calculated from the calories.
    func calculatedAlcohol() -> Double? {
        guard
            let protein = self.macros?.protein,
            let fat = self.macros?.fat,
            let carbs = self.macros?.carbs
        else { return nil }

        let proteinCalories = protein * 4
        let fatCalories = fat * 9
        let carbsCalories = carbs * 4

        let macros = proteinCalories + fatCalories + carbsCalories
        return Double(self.calories - macros) / 98
    }
}
