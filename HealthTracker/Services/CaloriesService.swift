import Foundation

extension [ConsumedCalories] {
    /// The protein data entries.
    var proteinEntries: [DataEntry] {
        self.filter { $0.macros.protein != nil }.map {
            $0.asEntry($0.macros.protein!)
        }
    }

    /// The fat data entries.
    var fatEntries: [DataEntry] {
        self.filter { $0.macros.fat != nil }.map {
            $0.asEntry($0.macros.fat!)
        }
    }

    /// The carbs data entries.
    var carbsEntries: [DataEntry] {
        self.filter { $0.macros.carbs != nil }.map {
            $0.asEntry($0.macros.carbs!)
        }
    }
}

extension [BurnedCalories] {
    /// The consumed calories as negative data points.
    var consumedEntries: [DataEntry] {
        self.map { $0.asEntry(-Double($0.burned)) }
    }

    /// The duration of the activities.
    var durationEntries: [DataEntry] {
        self.filter { $0.duration != nil }.map { $0.asEntry($0.duration!) }
    }
}

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
