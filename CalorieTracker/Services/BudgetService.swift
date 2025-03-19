import Foundation

struct BudgetService {
    let budget: Double
    let entries: [Double]

    /// The total amount of of the budget consumed.
    var consumed: Double { entries.sum() }
    /// The remaining amount of the budget.
    var remaining: Double { budget - consumed }

    /// The progress of the budget. It is a value between 0 and 1.
    var progress: Double {
        return consumed / budget
    }

    init(_ budget: Double, on entries: [Double]) throws {
        guard budget > 0 else {
            throw DataError.InvalidData("Budget must be greater than 0.")
        }

        self.budget = budget
        self.entries = entries
    }
}
