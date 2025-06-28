import Foundation
import HealthKit
import SwiftUI

// MARK: Service
// ============================================================================

/// Service for querying HealthKit data with model-specific query methods.
public class HealthKitService: @unchecked Sendable {
    internal static let shared = HealthKitService()
    internal let logger = AppLogger.new(for: HealthKitService.self)
    internal let store = HKHealthStore()

    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    // Sample query sorting
    internal var defaultSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate, ascending: false
        )
    }

    // User unit preferences
    @MainActor
    internal static var unitsCache: [HKQuantityType: Unit] = [:]

    // Observation management
    internal var activeObservers: [String: HKObserverQuery] = [:]
    internal let observerQueue = DispatchQueue(
        label: ObserversID, qos: .utility
    )

    private init() {
        guard Self.isAvailable else {
            logger.debug("HealthKit unavailable, skipping initialization")
            return
        }

        Task { await setupUnits() }
        logger.info("HealthKit service initialized.")
    }
}

// MARK: Environment Integration
// ============================================================================

extension EnvironmentValues {
    /// The HealthKit service used for querying HealthKit data.
    @Entry public var healthKit: HealthKitService = .shared
}
