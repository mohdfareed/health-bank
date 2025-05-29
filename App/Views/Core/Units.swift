import Foundation
import SwiftData
import SwiftUI

// MARK: Weight
// ============================================================================

extension Weight {
    @MainActor var measurement: LocalizedMeasurement<UnitMass> {
        LocalizedMeasurement(
            Binding(
                get: { self.weight },
                set: { self.weight = $0 }
            ),
            definition: UnitDefinition(
                .kilograms, alts: [.pounds], usage: .personWeight
            )
        )
    }
}

// MARK: Calorie
// ============================================================================

extension Calorie {
    @MainActor var measurement: LocalizedMeasurement<UnitEnergy> {
        LocalizedMeasurement(
            Binding(
                get: { self.calories },
                set: { self.calories = $0 }
            ),
            definition: UnitDefinition(.kilocalories, usage: .food)
        )
    }
}

// MARK: Macros
// ============================================================================

extension DietaryEnergy {
    @MainActor var carbsMeasurement: LocalizedMeasurement<UnitMass> {
        LocalizedMeasurement(
            Binding(
                get: { self.macros.carbs },
                set: { self.macros.carbs = $0 }
            ),
            definition: UnitDefinition(.grams, usage: .asProvided)
        )
    }
    @MainActor var proteinMeasurement: LocalizedMeasurement<UnitMass> {
        LocalizedMeasurement(
            Binding(
                get: { self.macros.protein },
                set: { self.macros.protein = $0 }
            ),
            definition: UnitDefinition(.grams, usage: .asProvided)
        )
    }
    @MainActor var fatMeasurement: LocalizedMeasurement<UnitMass> {
        LocalizedMeasurement(
            Binding(
                get: { self.macros.fat },
                set: { self.macros.fat = $0 }
            ),
            definition: UnitDefinition(.grams, usage: .asProvided)
        )
    }
}

// MARK: Activity
// ============================================================================

extension ActiveEnergy {
    @MainActor var durationMeasurement: LocalizedMeasurement<UnitDuration> {
        LocalizedMeasurement(
            Binding(
                get: { self.duration },
                set: { self.duration = $0 }
            ),
            definition: UnitDefinition(
                .minutes, alts: [.seconds, .hours], usage: .asProvided
            )
        )
    }
}
