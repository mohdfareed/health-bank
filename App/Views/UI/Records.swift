import SwiftUI

// MARK: Field Definition Registry
// ============================================================================

/// Record Field definition that centralizes properties for a health metric.
struct RecordViewDefinition<Unit: Dimension>: Sendable {
    let title: String.LocalizationValue
    let image: Image
    let tint: Color

    let unitDefinition: UnitDefinition<Unit>
    let validator: (@Sendable (Double) -> Bool)?
    let formatter: FloatingPointFormatStyle<Double>

    @MainActor
    func measurement(_ value: Binding<Double?>) -> LocalizedMeasurement<Unit> {
        LocalizedMeasurement(value, definition: unitDefinition)
    }
}

// MARK: Field Definitions Registry
// ============================================================================

enum FieldRegistry {
    // Weight
    static let weight = RecordViewDefinition<UnitMass>(
        title: "Weight",
        image: .weight,
        tint: .weight,
        unitDefinition: UnitDefinition(
            .kilograms, alts: [.pounds], usage: .personWeight
        ),
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Generic Calories (for goals, etc.)
    static let calorie = RecordViewDefinition<UnitEnergy>(
        title: "Calories",
        image: .calories,
        tint: .calories,
        unitDefinition: UnitDefinition(.kilocalories, usage: .food),
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Dietary Calories
    static let dietaryCalorie = RecordViewDefinition<UnitEnergy>(
        title: "Calories",
        image: .dietaryCalorie,
        tint: .dietaryCalorie,
        unitDefinition: UnitDefinition(.kilocalories, usage: .food),
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Active Calories
    static let activeCalorie = RecordViewDefinition<UnitEnergy>(
        title: "Calories",
        image: .activeCalorie,
        tint: .activeCalorie,
        unitDefinition: UnitDefinition(.kilocalories, usage: .food),
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Resting Calories
    static let restingCalorie = RecordViewDefinition<UnitEnergy>(
        title: "Calories",
        image: .restingCalorie,
        tint: .restingCalorie,
        unitDefinition: UnitDefinition(.kilocalories, usage: .food),
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Protein (macros)
    static let protein = RecordViewDefinition<UnitMass>(
        title: "Protein",
        image: .protein,
        tint: .protein,
        unitDefinition: UnitDefinition(.grams, usage: .asProvided),
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Carbs (macros)
    static let carbs = RecordViewDefinition<UnitMass>(
        title: "Carbohydrates",
        image: .carbs,
        tint: .carbs,
        unitDefinition: UnitDefinition(.grams, usage: .asProvided),
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Fat (macros)
    static let fat = RecordViewDefinition<UnitMass>(
        title: "Fat",
        image: .fat,
        tint: .fat,
        unitDefinition: UnitDefinition(.grams, usage: .asProvided),
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Activity Duration
    static let activity = RecordViewDefinition<UnitDuration>(
        title: "Duration",
        image: .activeCalorie,
        tint: .activeCalorie,
        unitDefinition: UnitDefinition(
            .minutes, alts: [.seconds, .hours], usage: .asProvided
        ),
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )
}
