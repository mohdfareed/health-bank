import Combine
import SwiftData
import SwiftUI

@Observable
final class DashboardVM {
    var budgetVM: BudgetVM

    init(context: ModelContext, budget: CalorieBudget) {
        self.budgetVM = BudgetVM(
            budget: budget,
            caloriesService: CaloriesService(context: context)
        )
    }
}
