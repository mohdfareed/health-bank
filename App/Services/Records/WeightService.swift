import Foundation

// MARK: Budgets and Goals
// ============================================================================

extension UserGoals {
    /// The calories daily budget.
    var weightGoal: Weight {
        get {
            .init(weight ?? 0, date: date)
        }
        set {
            self.date = newValue.date
            self.weight = newValue.weight
        }
    }
}
