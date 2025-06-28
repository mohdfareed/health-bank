import Foundation
import SwiftUI

// MARK: Budget Service
// ============================================================================

@MainActor @propertyWrapper
public struct MacrosAnalytics: DynamicProperty {
    @Environment(\.healthKit)
    var healthKitService: HealthKitService

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
        guard let protein = await dataService(for: .protein, at: date) else { return }
        guard let carbs = await dataService(for: .carbs, at: date) else { return }
        guard let fat = await dataService(for: .fat, at: date) else { return }

        let newAnalytics = MacrosAnalyticsService(
            calories: budgetAnalytics,
            protein: protein, carbs: carbs, fat: fat,
            adjustments: adjustments, daysLeft: budgetAnalytics?.daysLeft ?? 0
        )

        await MainActor.run {
            withAnimation(.default) {
                analytics = newAnalytics
            }
        }
    }

    private func dataService(
        for: HealthKitDataType, at date: Date
    ) async -> DataAnalyticsService? {
        guard let ranges = dateRanges(from: date) else { return nil }

        // Get data for the EWMA average
        let ewmaData = await healthKitService.fetchStatistics(
            for: `for`,
            from: ranges.ewma.from, to: ranges.ewma.to,
            interval: .daily,
            options: .cumulativeSum
        )

        // Get data for the current intake
        let currentData = await healthKitService.fetchStatistics(
            for: `for`,
            from: ranges.current.from, to: ranges.current.to,
            interval: .daily,
            options: .cumulativeSum
        )

        // Create services
        return DataAnalyticsService(
            currentIntakes: currentData,
            intakes: ewmaData, alpha: 0.25,
        )
    }

    private func dateRanges(from date: Date) -> (
        ewma: (from: Date, to: Date), current: (from: Date, to: Date)
    )? {
        // REVIEW: Add a setting to control the range
        let yesterday = date.adding(-1, .day, using: .autoupdatingCurrent)
        let ewmaRange = yesterday?.dateRange(by: 7, using: .autoupdatingCurrent)
        let currentRange = date.dateRange(using: .autoupdatingCurrent)

        guard let ewmaRange, let currentRange else {
            AppLogger.new(for: self).error(
                "Failed to calculate date ranges for macros EWMA at: \(date)"
            )
            return nil
        }
        return (ewma: ewmaRange, current: currentRange)
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
