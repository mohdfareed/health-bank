import Combine
import SwiftData
import SwiftUI

@Observable
class BudgetVM {
    var name: String
    var budget: Int = 0
    var consumed: Int = 0
    var remaining: Int = 0
    var progress: Double {
        guard self.budget > 0 else {
            return 1
        }

        return Double(self.consumed) / Double(self.budget)
    }

    internal let logger = AppLogger.new(category: "\(BudgetVM.self)")
    private let statisticsService: CalorieStatisticsService

    init(statisticsService: CalorieStatisticsService) {
        self.statisticsService = statisticsService
        refreshData(for: Date.now)
        self.logger.debug("Budget VM initialized.")
    }

    func refreshData(for date: Date) {
        self.name = self.statisticsService.budget.name
        self.budget = self.statisticsService.budget.calories
        self.consumed = self.statisticsService.consumedCalories
        self.remaining = self.statisticsService.remainingCalories
        self.logger.debug("Loaded state for budget: \(self.name)")
    }
}
