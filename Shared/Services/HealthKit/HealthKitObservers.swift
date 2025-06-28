import Foundation
import HealthKit
import SwiftUI
import WidgetKit

// MARK: Observer Management
// ============================================================================

extension HealthKitService {
    /// Start observing HealthKit data changes for a specific widget
    public func startObserving(
        for widgetKind: String, dataTypes: [HealthKitDataType],
        from startDate: Date, to endDate: Date,
        onUpdate: @escaping @Sendable () -> Void
    ) {
        guard Self.isAvailable else { return }

        // Stop any existing observers for this widget
        stopObserving(for: widgetKind)
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate, end: endDate
        )

        for dataType in dataTypes {
            let observerKey = observerKey(for: widgetKind, dataType: dataType)
            let observer = HKObserverQuery(
                sampleType: dataType.sampleType,
                predicate: predicate
            ) { [weak self] query, completionHandler, error in
                guard let self = self else {
                    completionHandler()
                    return
                }

                if let error = error {
                    self.logger.error(
                        "Observer error for \(observerKey): \(error)"
                    )

                    // Retry after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.startObserving(
                            for: widgetKind, dataTypes: [dataType],
                            from: startDate, to: endDate,
                            onUpdate: onUpdate
                        )
                    }
                    completionHandler()
                    return
                }

                self.logger.debug(
                    "HealthKit data changed for \(observerKey)"
                )

                // Trigger widget update on main queue
                DispatchQueue.main.async {
                    onUpdate()
                }
                completionHandler()
            }

            activeObservers[observerKey] = observer
            self.store.execute(observer)
            logger.info("Started observing: \(observerKey)")
        }
    }

    /// Stop observing HealthKit data changes for a specific widget
    public func stopObserving(for widgetKind: String) {
        let observersToRemove = activeObservers.filter { key, _ in
            key.hasPrefix("\(widgetKind)_")
        }

        for (key, observer) in observersToRemove {
            self.store.stop(observer)
            activeObservers.removeValue(forKey: key)
            logger.info("Stopped observer: \(key)")
        }
    }

    /// Stop all active observers
    public func stopAllObservers() {
        for (key, observer) in activeObservers {
            self.store.stop(observer)
            logger.info("Stopped observer: \(key)")
        }
        activeObservers.removeAll()
    }

    /// Get the observer key for a specific widget and data type
    public func observerKey(
        for widgetKind: String, dataType: HealthKitDataType
    ) -> String { "\(widgetKind)_\(dataType.sampleType.identifier)" }
}
