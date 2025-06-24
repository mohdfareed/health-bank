import Foundation
import HealthKit
import SwiftUI
import WidgetKit

// MARK: Widget Observer Service
// ============================================================================

/// Service for managing HealthKit observer queries that trigger widget updates
public class HealthKitObservers: @unchecked Sendable {
    public static let shared = HealthKitObservers()
    internal let logger = AppLogger.new(for: HealthKitObservers.self)
    internal let healthKitService = HealthKitService.shared

    private var activeObservers: [String: HKObserverQuery] = [:]
    private let observerQueue = DispatchQueue(label: ObserversID, qos: .utility)

    private init() {
        logger.info("HealthKit observers service initialized.")
    }
}

// MARK: Observer Management
// ============================================================================

extension HealthKitObservers {
    /// Start observing HealthKit data changes for a specific widget
    public func startObserving(
        for widgetKind: String,
        dataTypes: [HealthKitDataType],
        onUpdate: @escaping @Sendable () -> Void
    ) {
        guard HealthKitService.isAvailable else {
            logger.warning("HealthKit unavailable, skipping observer setup for \(widgetKind)")
            return
        }

        // Stop any existing observers for this widget
        stopObserving(for: widgetKind)

        for dataType in dataTypes {
            let observerKey = "\(widgetKind)_\(dataType.sampleType.identifier)"

            let observer = HKObserverQuery(
                sampleType: dataType.sampleType,
                predicate: nil
            ) { [weak self] query, completionHandler, error in
                guard let self = self else {
                    completionHandler()
                    return
                }

                if let error = error {
                    self.logger.error(
                        "Observer error for \(widgetKind) - \(dataType.sampleType.identifier): \(error)"
                    )
                    // Retry after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.restartObserver(
                            for: widgetKind, dataType: dataType, onUpdate: onUpdate)
                    }
                } else {
                    self.logger.debug(
                        "HealthKit data changed for \(widgetKind) - \(dataType.sampleType.identifier)"
                    )

                    // Trigger widget update on main queue
                    DispatchQueue.main.async {
                        onUpdate()
                    }
                }

                completionHandler()
            }

            activeObservers[observerKey] = observer
            healthKitService.store.execute(observer)

            logger.info(
                "Started observing \(dataType.sampleType.identifier) for widget: \(widgetKind)")
        }
    }

    /// Stop observing HealthKit data changes for a specific widget
    public func stopObserving(for widgetKind: String) {
        let observersToRemove = activeObservers.filter { key, _ in
            key.hasPrefix("\(widgetKind)_")
        }

        for (key, observer) in observersToRemove {
            healthKitService.store.stop(observer)
            activeObservers.removeValue(forKey: key)
            logger.info("Stopped observer: \(key)")
        }
    }

    /// Stop all active observers
    public func stopAllObservers() {
        for (key, observer) in activeObservers {
            healthKitService.store.stop(observer)
            logger.info("Stopped observer: \(key)")
        }
        activeObservers.removeAll()
    }

    /// Restart a specific observer (used for error recovery)
    private func restartObserver(
        for widgetKind: String,
        dataType: HealthKitDataType,
        onUpdate: @escaping @Sendable () -> Void
    ) {
        logger.info("Restarting observer for \(widgetKind) - \(dataType.sampleType.identifier)")
        startObserving(for: widgetKind, dataTypes: [dataType], onUpdate: onUpdate)
    }
}

// MARK: Widget-Specific Observer Configurations
// ============================================================================

extension HealthKitObservers {
    /// Start observing for Budget Widget (calories and body mass)
    public func startBudgetWidgetObserver() {
        logger.info("Starting Budget Widget observer...")
        startObserving(
            for: BudgetWidgetID,
            dataTypes: [.dietaryCalories, .bodyMass],
            onUpdate: {
                AppLogger.new(for: HealthKitObservers.self).info(
                    "Budget widget data changed - reloading timeline")
                WidgetCenter.shared.reloadTimelines(ofKind: BudgetWidgetID)
            }
        )
    }

    /// Start observing for Macros Widget (protein, carbs, fat)
    public func startMacrosWidgetObserver() {
        logger.info("Starting Macros Widget observer...")
        startObserving(
            for: MacrosWidgetID,
            dataTypes: [.protein, .carbs, .fat, .dietaryCalories, .bodyMass],
            onUpdate: {
                AppLogger.new(for: HealthKitObservers.self).info(
                    "Macros widget data changed - reloading timeline")
                WidgetCenter.shared.reloadTimelines(ofKind: MacrosWidgetID)
            }
        )
    }

    /// Start observing for Overview Widget (all nutrition data)
    public func startOverviewWidgetObserver() {
        logger.info("Starting Overview Widget observer...")
        startObserving(
            for: OverviewWidgetID,
            dataTypes: [.dietaryCalories, .protein, .carbs, .fat, .bodyMass],
            onUpdate: {
                AppLogger.new(for: HealthKitObservers.self).info(
                    "Overview widget data changed - reloading timeline")
                WidgetCenter.shared.reloadTimelines(ofKind: OverviewWidgetID)
            }
        )
    }

    /// Start all widget observers
    public func startAllWidgetObservers() {
        startBudgetWidgetObserver()
        startMacrosWidgetObserver()
        startOverviewWidgetObserver()
    }

    /// Start unified observer for dashboard data changes
    public func startDashboardDataObserver() {
        logger.info("Starting unified Dashboard data observer...")
        startObserving(
            for: "Dashboard.Unified",
            dataTypes: [.dietaryCalories, .protein, .carbs, .fat, .bodyMass],
            onUpdate: {
                // Notify the modern SwiftUI notification system on main queue
                DispatchQueue.main.async {
                    HealthDataNotifications.shared.notifyDataChanged(
                        for: [.dietaryCalories, .protein, .carbs, .fat, .bodyMass]
                    )
                }
            }
        )
    }

    /// Start observing for Overview Widget (all nutrition data) - Legacy method
    @available(*, deprecated, message: "Use startOverviewWidgetObserver() instead")
    public func startNutritionWidgetObserver(widgetKind: String) {
        startObserving(
            for: widgetKind,
            dataTypes: [.dietaryCalories, .protein, .carbs, .fat, .bodyMass],
            onUpdate: {
                WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
            }
        )
    }
}

// MARK: Global Access
// ============================================================================

extension EnvironmentValues {
    @Entry public var healthKitObservers: HealthKitObservers = .shared
}
