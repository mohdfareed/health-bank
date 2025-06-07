import Foundation
import HealthKit
import SwiftUI

// TODO: Add background sync:
// https://developer.apple.com/documentation/swiftdata/modelcontext/didsave

// MARK: Service
// ============================================================================

/// Service for querying HealthKit data with model-specific query methods.
public final class HealthKitService: Sendable {
    public static let AppSource = AppName
    public static let AppSourceID = AppID

    internal let logger = AppLogger.new(for: HealthKitService.self)
    internal let store = HKHealthStore()

    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }
    var isActive: Bool {
        UserDefaults.standard.bool(for: .enableHealthKit) && Self.isAvailable
    }

    // Sample query sorting
    internal var chronologicalSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate, ascending: false
        )
    }
}

// MARK: Environment Integration
// ============================================================================

extension EnvironmentValues {
    /// The HealthKit service used for querying HealthKit data.
    @Entry var healthKit: HealthKitService = .init()
}

extension View {
    /// Sets the HealthKit service for the view's environment.
    func healthKit(_ service: HealthKitService) -> some View {
        environment(\.healthKit, service)
    }
}

// MARK: Extensions
// ============================================================================

extension HKSource {
    /// Returns whether the source is internal to the app.
    var isInternal: Bool {
        self.bundleIdentifier == HealthKitService.AppSourceID
    }
}

extension [HKQuantitySample] {
    /// Sums the quantities in the array using the specified unit.
    func sum(as unit: HKUnit) -> Double? {
        guard !isEmpty else { return nil }
        return reduce(0) {
            return $0 + $1.quantity.doubleValue(for: unit)
        }
    }
}
