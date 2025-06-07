import Foundation
import HealthKit
import SwiftUI

enum HealthKitDataType: CaseIterable {
    case bodyMass
    case dietaryCalories, activeCalories, basalCalories
    case protein, carbs, fat
    case workout

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
        case .workout:
            return HKWorkoutType.workoutType()
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
        case .workout:
            return HKQuantityType(.appleExerciseTime)
        }
    }
}

// TODO: Add background sync:
// https://developer.apple.com/documentation/swiftdata/modelcontext/didsave
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
    var isActive: Bool {
        UserDefaults.standard.bool(for: .enableHealthKit) && Self.isAvailable
    }

    // Sample query sorting
    internal var chronologicalSortDescriptor: NSSortDescriptor {
        NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate, ascending: false
        )
    }

    // User unit preferences
    @MainActor
    static var unitsCache: [HKQuantityType: Unit] = [:]

    init() {
        Task {
            await setupUnits()
        }
        logger.info("HealthKit service initialized.")
    }

    // MARK: Sample Queries

    /// Execute a sample query for the given date range.
    public func fetchSamples(
        for type: HKSampleType,
        from startDate: Date, to endDate: Date, limit: Int?,
        predicate: NSPredicate? = nil
    ) async -> [HKSample] {
        guard isActive else {
            logger.debug("HealthKit inactive, returning empty results")
            return []
        }

        return await withCheckedContinuation { continuation in
            let predicate =
                predicate
                ?? HKQuery.predicateForSamples(
                    withStart: startDate, end: endDate,
                    options: .strictEndDate
                )

            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate, limit: limit ?? HKObjectQueryNoLimit,
                sortDescriptors: [chronologicalSortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    self.logger.error(
                        "Failed to fetch \(type.identifier): \(error)"
                    )
                    continuation.resume(returning: [])
                } else {
                    continuation.resume(returning: samples ?? [])
                }
            }
            store.execute(query)
        }
    }

    // MARK: Correlation Queries

    /// Execute a correlation sample query for the given date range.
    public func fetchCorrelationSamples(
        for type: HKCorrelationType,
        from startDate: Date, to endDate: Date
    ) async -> [HKCorrelation] {
        guard isActive else {
            logger.debug("HealthKit inactive, returning empty results")
            return []
        }

        let samples: [HKCorrelation] = await withCheckedContinuation { cont in
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate, end: endDate,
                options: .strictEndDate
            )

            let query = HKCorrelationQuery(
                type: type, predicate: predicate, samplePredicates: nil
            ) { _, correlations, error in
                if let error = error {
                    self.logger.error(
                        "Failed to fetch \(type.identifier): \(error)"
                    )
                    cont.resume(returning: [])
                } else {
                    cont.resume(returning: correlations ?? [])
                }
            }
            store.execute(query)
        }

        return samples
    }
}

// MARK: Environment Integration
// ============================================================================

extension EnvironmentValues {
    /// The HealthKit service used for querying HealthKit data.
    @Entry var healthKit: HealthKitService = .shared
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
    /// Returns the data source of the HealthKit source.
    var dataSource: DataSource {
        switch bundleIdentifier {
        case HealthKitService.AppSourceID:
            return .app
        case "com.apple.Health":
            return .healthKit
        default:
            AppLogger.new(for: HealthKitService.self).debug(
                "Unknown source: \(self.bundleIdentifier)"
            )
            return .other(name)
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

// MARK: Data Reset
// ============================================================================

extension HealthKitService {
    /// Delete all HealthKit data for the app.
    @MainActor public func eraseData() async throws {
        guard isActive else { return }

        logger.info("Resetting HealthKit data...")
        let types = HealthKitDataType.allCases.map { $0.sampleType }
        let predicate = HKQuery.predicateForSamples(
            withStart: nil, end: nil, options: .strictEndDate
        )

        for type in types {
            try await store.deleteObjects(of: type, predicate: predicate)
        }
        logger.info("HealthKit data reset completed.")
    }
}
