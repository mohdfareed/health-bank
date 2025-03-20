import Foundation

struct BudgetService {
    /// The allocated budget amount.
    let budget: Double
    /// The total amount of of the budget consumed.
    let consumed: Double
    /// The remaining amount of the budget.
    var remaining: Double
    /// The progress of the budget. It is a value between 0 and 1.
    var progress: Double

    init(_ budget: Double, on entries: [Double]) throws {
        guard budget > 0 else {
            throw DataError.InvalidData("Budget must be greater than 0.")
        }

        self.budget = budget
        self.consumed = entries.sum()
        self.remaining = budget - consumed
        self.progress = consumed / budget
    }
}
