import Foundation

/// A budget service that calulcates budgetting statistics based on a budget and data entries.
struct BudgetService<T: Numeric> {
    /// The allocated budget amount.
    let budget: T
    /// The total amount of of the budget consumed.
    let consumed: T
    /// The remaining amount of the budget.
    var remaining: T
    /// The progress of the budget. It is a value between 0 and 1.
    var progress: T

    init(_ budget: T, on entries: [T]) throws {
        guard budget.magnitude > T.zero.magnitude else {
            throw DataError.InvalidData("Budget must be greater than 0.")
        }

        self.budget = budget
        self.consumed = entries.sum()
        self.remaining = budget - consumed
        self.progress = consumed / budget
    }
}
