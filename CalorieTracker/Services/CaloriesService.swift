import Foundation

extension [ConsumedCalories] {
    var caloriesDataPoint: DataPoints {
        return self.map { Double($0.consumed) }
    }

    var proteinDataPoints: DataPoints {
        return self.map { $0.macros.protein ?? 0 }
    }

    var fatDataPoints: DataPoints {
        return self.map { $0.macros.fat ?? 0 }
    }

    var carbsDataPoints: DataPoints {
        return self.map { $0.macros.carbs ?? 0 }
    }
}

extension [BurnedCalories] {
    var caloriesDataPoints: DataPoints {
        return self.map { -Double($0.burned) }
    }

    var ActivityDataPoint: DataPoints {
        return self.map { Double($0.burned) }
    }

    var durationDataPoints: DataPoints {
        return self.map { $0.duration ?? 0 }
    }

}

extension CalorieMacros {
    /// The total calories from the macros.
    var calories: UInt? {
        guard let p = self.protein, let f = self.fat, let c = self.carbs else {
            return nil
        }
        return UInt(((p + c) * 4) + (f * 9))
    }

    /// The amount of protein in grams from the given calories.
    /// - Parameter calories: The total calories.
    /// - Returns: Protein in grams. `nil` if not enough information.
    func fat(from calories: UInt) -> Double? {
        guard let protein = self.protein, let carbs = self.carbs else {
            return nil
        }

        let proteinCalories = protein * 4
        let carbsCalories = carbs * 4
        return (Double(calories) - proteinCalories - carbsCalories) / 9
    }

    /// The amount of fat in grams from the given calories.
    /// - Parameter calories: The total calories.
    /// - Returns: Fat in grams. `nil` if not enough information.
    func protein(from calories: UInt) -> Double? {
        guard let fat = self.fat, let carbs = self.carbs else {
            return nil
        }

        let fatCalories = fat * 9
        let carbsCalories = carbs * 4
        return (Double(calories) - fatCalories - carbsCalories) / 4
    }

    /// The amount of carbs in grams from the given calories.
    /// - Parameter calories: The total calories.
    /// - Returns: Carbs in grams. `nil` if not enough information.
    func carbs(from calories: UInt) -> Double? {
        guard let protein = self.protein, let fat = self.fat else {
            return nil
        }

        let proteinCalories = protein * 4
        let fatCalories = fat * 9
        return (Double(calories) - proteinCalories - fatCalories) / 4
    }
}
