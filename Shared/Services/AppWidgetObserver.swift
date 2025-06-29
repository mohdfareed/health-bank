import Foundation
import WidgetKit

/// Single app-level observer for widget refresh notifications
public final class AppWidgetObserver: @unchecked Sendable {
    private let healthKitService: HealthKitService
    private let logger = AppLogger.new(for: AppWidgetObserver.self)
    private var isObserving = false

    public init(healthKitService: HealthKitService) {
        self.healthKitService = healthKitService
    }

    /// Start observing HealthKit changes for widget refresh
    public func startObserving() {
        guard !isObserving else {
            logger.warning("Already observing, skipping duplicate setup")
            return
        }

        // Calculate broad date range for all widget data
        let today = Date()
        let startDate = today.adding(-90, .day, using: .autoupdatingCurrent) ?? today
        let endDate = today.adding(1, .day, using: .autoupdatingCurrent) ?? today

        // Single observer for all widget-relevant data types
        healthKitService.startObserving(
            for: "AppWidgetObserver",
            dataTypes: [.dietaryCalories, .bodyMass],
            from: startDate,
            to: endDate
        ) { [weak self] in
            self?.onHealthKitDataChanged()
        }

        isObserving = true
        logger.info("Started app-level widget observer")
    }

    /// Stop observing HealthKit changes
    public func stopObserving() {
        if isObserving {
            healthKitService.stopObserving(for: "AppWidgetObserver")
            isObserving = false
            logger.info("Stopped app-level widget observer")
        }
    }

    /// Handle HealthKit data changes by refreshing all widgets
    private func onHealthKitDataChanged() {
        logger.debug("HealthKit data changed, refreshing all widgets")
        Task {
            WidgetCenter.shared.reloadTimelines(ofKind: BudgetWidgetID)
            WidgetCenter.shared.reloadTimelines(ofKind: MacrosWidgetID)
        }
    }

    deinit {
        stopObserving()
    }
}
