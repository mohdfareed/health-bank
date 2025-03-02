import SwiftData
import SwiftUI

@Observable
class DailyBudgetVM: BudgetVM {
    override init(for budget: CalorieBudget, using entries: [CalorieEntry]) {
        super.init(for: budget, using: entries)
        self.name = "Daily Budget"
        self.budget = statisticsService.dailyBudget
        self.consumed = statisticsService.dailyConsumed
        self.remaining = statisticsService.dailyRemaining

        self.progress = {
            guard self.budget > 0 else {
                return nil
            }

            return Double(self.consumed) / Double(self.budget)
        }()
        self.logger.debug("Loaded state for daily budget: \(self.name)")
        self.logger.debug("Progress: \(self.progress ?? -1)")
    }
}

struct DailyBudgetView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var entries: [CalorieEntry]
    var vm: BudgetVM { DailyBudgetVM(for: self.budget, using: self.entries) }

    private let date: Date
    private let budget: CalorieBudget

    var body: some View {
        BudgetCard(
            viewModel: self.vm
        ) {
            BudgetRow(title: "Budget", text: "\(self.vm.budget) cal")
            BudgetRow(title: "Consumed", text: "\(self.vm.consumed) cal")
            BudgetRow(title: "Remaining", text: "\(self.vm.remaining) cal")
        }
    }

    init(budget: CalorieBudget, at date: Date) {
        self.date = date
        self.budget = budget
        self._entries = Query(CaloriesService.query(self.budget, on: date))
    }
}
