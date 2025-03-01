import Combine
import SwiftData
import SwiftUI

final class DashboardVM: ObservableObject {
    var budgetVM: BudgetVM

    init(context: ModelContext, budget: CalorieBudget) {
        self.budgetVM = BudgetVM(
            budget: budget,
            caloriesService: CaloriesService(context: context)
        )
    }
}
