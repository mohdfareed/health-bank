import Combine
import SwiftData
import SwiftUI

final class BudgetVM: ObservableObject {
    @Published var budgetName: String = "Budget"

    @Published var caloriesBudget: Int = 0
    @Published var consumedCalories: Int = 0
    @Published var remainingCalories: Int = 0

    @Published var dailyBudget: Int = 0
    @Published var dailyConsumed: Int = 0
    @Published var dailyRemaining: Int = 0

    private let budget: CalorieBudget
    private let statisticsService: CalorieStatisticsService

    init(budget: CalorieBudget, caloriesService: CaloriesService) {
        self.budget = budget
        self.statisticsService = try! CalorieStatisticsService(
            budget: budget,
            caloriesService: caloriesService,
            date: Date.now
        )
        refreshData(for: Date.now)
    }

    func refreshData(for date: Date) {
        self.caloriesBudget = self.statisticsService.budget.budget
        self.consumedCalories = self.statisticsService.consumedCalories
        self.remainingCalories = self.statisticsService.remainingCalories

        self.dailyBudget = self.statisticsService.dailyBudget
        self.dailyConsumed = self.statisticsService.dailyConsumed
        self.dailyRemaining = self.statisticsService.dailyRemaining
    }
}
