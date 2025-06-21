import Foundation
import SwiftUI

// MARK: Budget Service
// ============================================================================

@MainActor @propertyWrapper
public struct MacrosAnalytics: DynamicProperty {
    @Environment(\.healthKit)
    var healthKitService: HealthKitService
    let analyticsService: AnalyticsService = .init()

    @BudgetAnalytics var budgetAnalytics: BudgetService?
    @State var analytics: MacrosAnalyticsService?

    let adjustments: CalorieMacros?
    public init(
        budgetAnalytics: BudgetAnalytics,
        adjustments: CalorieMacros? = nil
    ) {
        self._budgetAnalytics = budgetAnalytics
        self.adjustments = adjustments
    }

    public var wrappedValue: MacrosAnalyticsService? {
        analytics
    }
    public var projectedValue: Self { self }

    public func reload(at date: Date) async {
        await $budgetAnalytics.reload(at: date)
        let newAnalytics = MacrosAnalyticsService(
            budget: budgetAnalytics,
            protein: await reloadProtein(at: date),
            carbs: await reloadCarbs(at: date),
            fat: await reloadFat(at: date),
            adjustments: adjustments,
            daysLeft: budgetAnalytics?.daysLeft ?? 0
        )

        await MainActor.run {
            withAnimation(.default) {
                analytics = newAnalytics
            }
        }
    }

    private func reloadProtein(at date: Date) async -> DataAnalyticsService {
        let ewmaRange = DataAnalyticsService.ewmaDateRange(from: date)
        let currentRange = DataAnalyticsService.currentDateRange(from: date)

        // Get calorie data for the past 7 days
        let calorieData = await healthKitService.fetchStatistics(
            for: .protein,
            from: ewmaRange.from, to: ewmaRange.to,
            interval: .daily,
            options: .cumulativeSum
        )

        // Get calorie data for the past 7 days
        let currentData = await healthKitService.fetchStatistics(
            for: .protein,
            from: currentRange.from, to: currentRange.to,
            interval: .daily,
            options: .cumulativeSum
        )

        // Create services
        return DataAnalyticsService(
            analytics: analyticsService,
            currentIntakes: currentData,
            intakes: calorieData, alpha: 0.25,
        )
    }

    private func reloadCarbs(at date: Date) async -> DataAnalyticsService {
        let ewmaRange = DataAnalyticsService.ewmaDateRange(from: date)
        let currentRange = DataAnalyticsService.currentDateRange(from: date)

        // Get calorie data for the past 7 days
        let calorieData = await healthKitService.fetchStatistics(
            for: .carbs,
            from: ewmaRange.from, to: ewmaRange.to,
            interval: .daily,
            options: .cumulativeSum
        )

        // Get calorie data for the past 7 days
        let currentData = await healthKitService.fetchStatistics(
            for: .carbs,
            from: currentRange.from, to: currentRange.to,
            interval: .daily,
            options: .cumulativeSum
        )

        // Create services
        return DataAnalyticsService(
            analytics: analyticsService,
            currentIntakes: currentData,
            intakes: calorieData, alpha: 0.25,
        )
    }

    private func reloadFat(at date: Date) async -> DataAnalyticsService {
        let ewmaRange = DataAnalyticsService.ewmaDateRange(from: date)
        let currentRange = DataAnalyticsService.currentDateRange(from: date)

        // Get calorie data for the past 7 days
        let calorieData = await healthKitService.fetchStatistics(
            for: .fat,
            from: ewmaRange.from, to: ewmaRange.to,
            interval: .daily,
            options: .cumulativeSum
        )

        // Get calorie data for the past 7 days
        let currentData = await healthKitService.fetchStatistics(
            for: .fat,
            from: currentRange.from, to: currentRange.to,
            interval: .daily,
            options: .cumulativeSum
        )

        // Create services
        return DataAnalyticsService(
            analytics: analyticsService,
            currentIntakes: currentData,
            intakes: calorieData, alpha: 0.25,
        )
    }
}

extension MacrosAnalyticsService {
    enum MacroRing {
        case protein, carbs, fat
    }

    @ViewBuilder
    func progress(_ ring: MacroRing) -> some View {
        switch ring {
        case .protein:
            ProgressRing(
                value: self.baseBudgets?.protein ?? 1,
                progress: protein.currentIntake ?? 0,
                color: .protein,
                tip: (self.budgets?.protein ?? 1),
                tipColor: (self.credits?.protein ?? 0) >= 0 ? .green : .red,
                icon: Image.protein
            )
        case .carbs:
            ProgressRing(
                value: self.baseBudgets?.carbs ?? 1,
                progress: carbs.currentIntake ?? 0,
                color: .carbs,
                tip: (self.budgets?.carbs ?? 1),
                tipColor: (self.credits?.carbs ?? 0) >= 0 ? .green : .red,
                icon: Image.carbs
            )
        case .fat:
            ProgressRing(
                value: self.baseBudgets?.fat ?? 1,
                progress: fat.currentIntake ?? 0,
                color: .fat,
                tip: (self.budgets?.fat ?? 1),
                tipColor: (self.credits?.fat ?? 0) >= 0 ? .green : .red,
                icon: Image.fat
            )
        }
    }
}
