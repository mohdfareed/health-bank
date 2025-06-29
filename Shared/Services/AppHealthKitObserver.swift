import Foundation
import WidgetKit

// MARK: - App-Level HealthKit Observer
// ============================================================================

/// Centralized observer for HealthKit changes that triggers widget updates
/// and provides reactive notifications to views
public final class AppHealthKitObserver: @unchecked Sendable {
    public static let shared = AppHealthKitObserver()

    private let healthKitService: HealthKitService
    private let notifications: HealthDataNotifications
    private let logger = AppLogger.new(for: AppHealthKitObserver.self)

    private var isObserving = false
    private let observerQueue = DispatchQueue(label: "\(AppID).AppHealthKitObserver", qos: .utility)

    private init() {
        self.healthKitService = HealthKitService.shared
        self.notifications = HealthDataNotifications.shared
    }

    /// Start observing all HealthKit data types for app-wide reactive updates
    public func startObserving() {
        guard !isObserving else {
            logger.warning("Already observing, skipping duplicate setup")
            return
        }

        observerQueue.async { [weak self] in
            self?.setupObservers()
        }
    }

    /// Stop all observations
    public func stopObserving() {
        guard isObserving else { return }

        observerQueue.async { [weak self] in
            guard let self = self else { return }

            self.healthKitService.stopObserving(for: "AppHealthKitObserver")
            self.isObserving = false
            self.logger.info("Stopped app-level HealthKit observer")
        }
    }

    private func setupObservers() {
        // Calculate broad date range for all health data (covers all use cases)
        let today = Date()
        let startDate = today.adding(-90, .day, using: .autoupdatingCurrent) ?? today
        let endDate = today.adding(1, .day, using: .autoupdatingCurrent) ?? today

        // Observe all HealthKit data types the app uses
        let dataTypes: [HealthKitDataType] = [
            .dietaryCalories, .bodyMass, .protein, .carbs, .fat, .alcohol,
        ]

        healthKitService.startObserving(
            for: "AppHealthKitObserver",
            dataTypes: dataTypes,
            from: startDate,
            to: endDate
        ) { [weak self] in
            self?.onHealthKitDataChanged(dataTypes: dataTypes)
        }

        isObserving = true
        logger.info(
            "Started app-level HealthKit observer for data types: \(dataTypes.map(\.sampleType.identifier))"
        )
    }

    private func onHealthKitDataChanged(dataTypes: [HealthKitDataType]) {
        logger.debug("HealthKit data changed for types: \(dataTypes.map(\.sampleType.identifier))")

        // Notify the HealthDataNotifications service (for view reactivity)
        notifications.notifyDataChanged(for: dataTypes)

        // Trigger widget updates
        Task {
            await refreshWidgets()
        }
    }

    @MainActor
    private func refreshWidgets() {
        logger.debug("Refreshing all widgets due to HealthKit data changes")
        WidgetCenter.shared.reloadTimelines(ofKind: BudgetWidgetID)
        WidgetCenter.shared.reloadTimelines(ofKind: MacrosWidgetID)
    }
}
