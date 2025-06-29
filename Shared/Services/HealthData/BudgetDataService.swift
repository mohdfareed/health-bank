import Foundation
import Observation
import SwiftUI
import WidgetKit

// MARK: - Budget Data Service
// ============================================================================

/// Observable service for budget data with automatic HealthKit integration
@Observable
public final class BudgetDataService: @unchecked Sendable {
    @MainActor public private(set) var budgetService: BudgetService?
    @MainActor public private(set) var isLoading: Bool = false

    // Injected dependencies
    private let healthKitService: HealthKitService
    private let adjustment: Double?
    private let date: Date

    private let logger = AppLogger.new(for: BudgetDataService.self)
    private var observerWidgetId: String?

    public init(
        healthKitService: HealthKitService? = nil,
        adjustment: Double? = nil,
        date: Date = Date()
    ) {
        self.healthKitService = healthKitService ?? HealthKitService.shared
        self.adjustment = adjustment
        self.date = date
        logger.info(
            "BudgetDataService initialized with adjustment: \(adjustment ?? 0)"
        )
    }

    // MARK: - Public Interface

    /// Refresh budget data from HealthKit
    @MainActor
    public func refresh() async {
        guard !isLoading else {
            logger.warning("Refresh already in progress, skipping")
            return
        }
        isLoading = true

        // Calculate date ranges for data fetching
        let yesterday = date.adding(-1, .day, using: .autoupdatingCurrent)

        guard let ewmaRange = yesterday?.dateRange(by: 7, using: .autoupdatingCurrent),
            let currentRange = date.dateRange(using: .autoupdatingCurrent),
            let fittingRange = yesterday?.dateRange(by: 90, using: .autoupdatingCurrent)
        else {
            logger.error("Failed to calculate date ranges for budget data")
            isLoading = false
            return
        }

        // Fetch data

        let calorieData = await healthKitService.fetchStatistics(
            for: .dietaryCalories,
            from: ewmaRange.from, to: ewmaRange.to,
            interval: .daily,
            options: .cumulativeSum
        )

        let maintenanceCalorieData = await healthKitService.fetchStatistics(
            for: .dietaryCalories,
            from: fittingRange.from, to: fittingRange.to,
            interval: .daily,
            options: .cumulativeSum
        )

        let currentCalorieData = await healthKitService.fetchStatistics(
            for: .dietaryCalories,
            from: currentRange.from, to: currentRange.to,
            interval: .daily,
            options: .cumulativeSum
        )

        let weightData = await healthKitService.fetchStatistics(
            for: .bodyMass,
            from: fittingRange.from, to: fittingRange.to,
            interval: .daily,
            options: .discreteAverage
        )

        // Create analytics services

        let weightAnalytics = WeightAnalyticsService(
            calories: DataAnalyticsService(
                currentIntakes: currentCalorieData,
                intakes: maintenanceCalorieData,
                alpha: 0.022  // 90 days
            ),
            weights: weightData,
            rho: 7700,
            alpha: 0.25,  // 7 days
        )

        // Create budget service with injected first weekday
        let newBudgetService = BudgetService(
            calories: DataAnalyticsService(
                currentIntakes: currentCalorieData,
                intakes: calorieData,
                alpha: 0.25  // 7 days
            ),
            weight: weightAnalytics,
            adjustment: adjustment,
            firstWeekday: Locale.autoupdatingCurrent.calendar.firstWeekday
        )

        await MainActor.run {
            withAnimation(.default) {
                budgetService = newBudgetService
                isLoading = false
            }
        }

        logger.debug("Budget data refreshed successfully")
    }

    /// Start observing HealthKit changes for automatic updates
    public func startObserving(widgetId: String = "BudgetDataService") {
        let yesterday = date.adding(-1, .day, using: .autoupdatingCurrent)
        guard let currentRange = date.dateRange(using: .autoupdatingCurrent),
            let fittingRange = yesterday?.dateRange(by: 90, using: .autoupdatingCurrent)
        else {
            logger.error("Failed to calculate date ranges for observation")
            return
        }

        let startDate = fittingRange.from
        let endDate = currentRange.to
        observerWidgetId = widgetId

        // Use existing HealthKit observer infrastructure
        healthKitService.startObserving(
            for: widgetId, dataTypes: [.dietaryCalories, .bodyMass],
            from: startDate, to: endDate
        ) { [weak self] in
            Task {
                await self?.refresh()
                // Trigger widget refresh when HealthKit data changes
                WidgetCenter.shared.reloadTimelines(ofKind: BudgetWidgetID)
            }
        }

        logger.info("Started observing HealthKit data for budget updates (widgetId: \(widgetId))")
    }

    /// Stop observing HealthKit changes
    public func stopObserving() {
        if let widgetId = observerWidgetId {
            healthKitService.stopObserving(for: widgetId)
            observerWidgetId = nil
            logger.info("Stopped observing HealthKit data for budget updates")
        }
    }

    deinit {
        stopObserving()
    }
}
