import SwiftData
import SwiftUI

@Observable
class BudgetVM: BudgetVMProtocol {
    var name: String
    var budget: Int
    var consumed: Int
    var remaining: Int
    var progress: Double?

    internal let logger = AppLogger.new(category: "\(BudgetVM.self)")
    internal let statisticsService: CalorieStatisticsService

    init(for budget: CalorieBudget, using entries: [CalorieEntry]) {
        self.statisticsService = CalorieStatisticsService(for: budget, using: entries)
        self.name = statisticsService.budget.name
        self.budget = statisticsService.budget.calories
        self.consumed = statisticsService.consumedCalories
        self.remaining = statisticsService.remainingCalories

        self.progress = {
            guard self.budget > 0 else {
                return nil
            }

            return Double(self.consumed) / Double(self.budget)
        }()
        self.logger.debug("Loaded state for budget: \(self.name)")
        self.logger.debug("Progress: \(self.progress ?? -1)")
    }
}

struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var entries: [CalorieEntry]
    // @State var vm: BudgetVM = BudgetVM(for: self.budget, using: self.entries)
    var vm: BudgetVM { BudgetVM(for: self.budget, using: self.entries) }

    private let date: Date
    private let budget: CalorieBudget

    var body: some View {
        // TODO: Add widget of bar chart of current cycle.
        // Color code bars based on macros.
        // Add macros widget.

        BudgetCard(viewModel: self.vm) {
            BudgetRow(title: "Budget", text: "\(self.vm.budget) cal")
            BudgetRow(title: "Consumed", text: "\(self.vm.consumed) cal")
            BudgetRow(title: "Remaining", text: "\(self.vm.remaining) cal")
        }
        DailyBudgetView(budget: self.budget, at: self.date)
    }

    init(budget: CalorieBudget, at date: Date) {
        self.date = date
        self.budget = budget
        self._entries = Query(CaloriesService.query(self.budget, on: date))
    }
}
