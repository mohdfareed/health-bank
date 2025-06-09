import Foundation
import HealthKit
import SwiftUI

// MARK: Supported Types
// ============================================================================

public enum HealthKitDataType: CaseIterable, Sendable {
    case bodyMass
    case dietaryCalories, activeCalories, basalCalories
    case protein, carbs, fat, alcohol

    var sampleType: HKSampleType {
        switch self {
        case .bodyMass:
            return HKQuantityType(.bodyMass)
        case .dietaryCalories:
            return HKQuantityType(.dietaryEnergyConsumed)
        case .activeCalories:
            return HKQuantityType(.activeEnergyBurned)
        case .basalCalories:
            return HKQuantityType(.basalEnergyBurned)
        case .protein:
            return HKQuantityType(.dietaryProtein)
        case .carbs:
            return HKQuantityType(.dietaryCarbohydrates)
        case .fat:
            return HKQuantityType(.dietaryFatTotal)
        case .alcohol:
            return HKQuantityType(.numberOfAlcoholicBeverages)
        }
    }

    var quantityType: HKQuantityType {
        switch self {
        case .bodyMass:
            return HKQuantityType(.bodyMass)
        case .dietaryCalories:
            return HKQuantityType(.dietaryEnergyConsumed)
        case .activeCalories:
            return HKQuantityType(.activeEnergyBurned)
        case .basalCalories:
            return HKQuantityType(.basalEnergyBurned)
        case .protein:
            return HKQuantityType(.dietaryProtein)
        case .carbs:
            return HKQuantityType(.dietaryCarbohydrates)
        case .fat:
            return HKQuantityType(.dietaryFatTotal)
        case .alcohol:
            return HKQuantityType(.numberOfAlcoholicBeverages)
        }
    }
}

// TODO: Support statistics queries for charts:
// https://developer.apple.com/documentation/healthkit/executing-statistics-collection-queries

// MARK: Service
// ============================================================================

/// Service for querying HealthKit data with model-specific query methods.
public class HealthKitService: @unchecked Sendable {
    internal static let shared = HealthKitService()

    public static let AppSource = AppName
    public static let AppSourceID = AppID

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
    static var unitsCache: [HKQuantityType: Unit] = [:]

    private init() {
        guard Self.isAvailable else {
            logger.debug("HealthKit unavailable, skipping initialization")
            return
        }

        Task { await setupUnits() }
        logger.info("HealthKit service initialized.")
    }
}

// MARK: Data Access
// ============================================================================

extension HealthKitService {
    /// Save a quantity sample to HealthKit.
    public func save(_ sample: HKObject) async throws {
        guard Self.isAvailable else { return }
        return try await withCheckedThrowingContinuation { continuation in
            store.save(sample) { success, error in
                if let error = error {
                    self.logger.error("Failed to save sample: \(error)")
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume(returning: ())
                } else {
                    let error = HealthKitError.saveFailed("Unknown save error")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Delete a sample from HealthKit.
    public func delete(_ id: UUID, of type: HKObjectType) async throws {
        guard Self.isAvailable else { return }
        let predicate = HKQuery.predicateForObject(with: id)
        try await store.deleteObjects(
            of: type, predicate: predicate
        )
    }
}

// MARK: Environment Integration
// ============================================================================

extension EnvironmentValues {
    /// The HealthKit service used for querying HealthKit data.
    @Entry var healthKit: HealthKitService = .shared
}

// MARK: Extensions
// ============================================================================

extension HKSource {
    /// Returns the data source of the HealthKit source.
    var dataSource: DataSource {
        switch bundleIdentifier.lowercased() {
        case HealthKitService.AppSourceID.lowercased():
            return .app
        case let id where id.hasPrefix("com.apple.health"):
            return .healthKit

        default:
            switch name.lowercased() {
            case HealthKitService.AppSource.lowercased():
                return .app
            case "health":
                return .healthKit
            default:
                return .other(name)
            }
        }
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

extension HKWorkoutBuilder {
    /// Creates a workout builder with the specified activity type.
    convenience init(activityType: HKWorkoutActivityType) {
        let config = HKWorkoutConfiguration()
        config.activityType = activityType

        self.init(
            healthStore: HealthKitService.shared.store,
            configuration: config, device: nil
        )
    }
}
