import Foundation

extension Budgets {
    /// The dietary energy for the budget, including macros.
    var energyBudget: DietaryEnergy {
        get {
            guard let calories = self.calories else { return .init(0) }
            return .init(calories, date: date, macros: macros)
        }
        set {
            self.date = newValue.date
            self.calories = newValue.calories
            self.macros = newValue.macros
        }
    }
}

extension Goals {
    /// The active energy goal.
    var energyGoal: ActiveEnergy {
        get {
            guard let calories = self.calories else { return .init(0) }
            return .init(calories, date: date, duration: activity)
        }
        set {
            self.date = newValue.date
            self.calories = newValue.calories
            self.activity = newValue.duration
        }
    }

    /// The weight goal.
    var weightGoal: Weight {
        get {
            guard let weight = self.weight else { return .init(0) }
            return .init(weight, date: date)
        }
        set {
            self.date = newValue.date
            self.weight = newValue.weight
        }
    }
}
