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
        if let alcohol = self.alcohol {
            let drinks = Measurement(
                value: alcohol, unit: UnitDefinition.alcohol.baseUnit
            ).converted(to: UnitVolume.standardDrink)
            return drinks.value * 98
        }

        guard
            let p = self.macros?.protein,
            let f = self.macros?.fat,
            let c = self.macros?.carbs
        else { return nil }
        let calc = ((p + c) * 4) + (f * 9)

        if calc < 0 {
            return nil
        }
        return calc
    }

    /// The amount of protein calculated from the calories, carbs, and fat.
    func calculatedProtein() -> Double? {
        guard
            let fat = self.macros?.fat,
            let carbs = self.macros?.carbs
        else { return nil }

        let fatCalories = fat * 9
        let carbsCalories = carbs * 4
        let calc = Double(self.calories - fatCalories - carbsCalories) / 4

        if calc < 0 {
            return nil
        }
        return calc
    }

    /// The amount of carbs calculated from the calories, protein, and fat.
    func calculatedCarbs() -> Double? {
        guard
            let protein = self.macros?.protein,
            let fat = self.macros?.fat
        else { return nil }

        let proteinCalories = protein * 4
        let fatCalories = fat * 9
        let calc = Double(self.calories - proteinCalories - fatCalories) / 4

        if calc < 0 {
            return nil
        }
        return calc
    }

    /// The amount of fat calculated from the calories, protein, and carbs.
    func calculatedFat() -> Double? {
        guard
            let protein = self.macros?.protein,
            let carbs = self.macros?.carbs
        else { return nil }

        let proteinCalories = protein * 4
        let carbsCalories = carbs * 4
        let calc = Double(self.calories - proteinCalories - carbsCalories) / 9

        if calc < 0 {
            return nil
        }
        return calc
    }

    /// The amount of alcohol calculated from the calories.
    func calculatedAlcohol() -> Double? {
        let drinks = calories / 98
        let calc = Measurement(
            value: drinks, unit: UnitVolume.standardDrink
        ).converted(to: UnitDefinition.alcohol.baseUnit)

        if calc.value < 0 {
            return nil
        }
        return calc.value
    }
}
