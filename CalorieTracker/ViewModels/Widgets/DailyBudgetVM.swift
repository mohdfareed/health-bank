import Combine
import SwiftData
import SwiftUI

@Observable
class DailyBudgetVM: BudgetVM {
    private let statisticsService: CalorieStatisticsService

    override init(statisticsService: CalorieStatisticsService) {
        self.statisticsService = statisticsService
        super.init(statisticsService: statisticsService)
        self.name = "Daily Budget"
    }

    override func refreshData(for date: Date) {
        self.budget = self.statisticsService.budget.calories
        self.consumed = self.statisticsService.consumedCalories
        self.remaining = self.statisticsService.remainingCalories
        self.logger.debug("Loaded state for daily budget.")
    }
}
