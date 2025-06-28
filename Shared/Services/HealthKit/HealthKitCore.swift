import Foundation
import HealthKit
import SwiftUI

// MARK: Supported Types
// ============================================================================

public enum HealthKitDataType: CaseIterable, Sendable {
    case bodyMass
    case dietaryCalories
    case protein, carbs, fat, alcohol
    // case activeCalories, basalCalories

    var sampleType: HKSampleType {
        switch self {
        case .bodyMass:
            return HKQuantityType(.bodyMass)
        case .dietaryCalories:
            return HKQuantityType(.dietaryEnergyConsumed)
        // case .activeCalories:
        //     return HKQuantityType(.activeEnergyBurned)
        // case .basalCalories:
        //     return HKQuantityType(.basalEnergyBurned)
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
        // case .activeCalories:
        //     return HKQuantityType(.activeEnergyBurned)
        // case .basalCalories:
        //     return HKQuantityType(.basalEnergyBurned)
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

// MARK: Extensions
// ============================================================================

extension HKSource {
    /// Returns the data source of the HealthKit source.
    var dataSource: DataSource {
        switch bundleIdentifier.lowercased() {
        case let id where id.hasSuffix(AppID.lowercased()):
            return .app
        case let id where id.hasPrefix("com.apple.health"):
            return .healthKit
        case let id where id.hasPrefix("com.apple.shortcuts"):
            return .shortcuts
        case let id where id.hasSuffix("FoodNoms".lowercased()):
            return .foodNoms

        default:
            switch name.lowercased() {
            case AppID.lowercased():
                return .app
            case "Health".lowercased():
                return .healthKit
            case "Shortcuts".lowercased():
                return .shortcuts
            case "FoodNoms".lowercased():
                return .foodNoms
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
