import SwiftUI

struct RecordFieldDefinition<Unit: Dimension>: Sendable {
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

// MARK: Field Definitions
// ============================================================================

/// Record Field definition that centralizes properties for a health metric.
enum FieldDefinition {
    // Weight
    static let weight = RecordFieldDefinition<UnitMass>(
        title: "Weight",
        image: .weight,
        tint: .weight,
        unitDefinition: .weight,
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Generic Calories (for goals, etc.)
    static let calorie = RecordFieldDefinition<UnitEnergy>(
        title: "Calories",
        image: .calories,
        tint: .calories,
        unitDefinition: .calorie,
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Dietary Calories
    static let dietaryCalorie = RecordFieldDefinition<UnitEnergy>(
        title: "Calories",
        image: .dietaryCalorie,
        tint: .dietaryCalorie,
        unitDefinition: .calorie,
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Active Calories
    static let activeCalorie = RecordFieldDefinition<UnitEnergy>(
        title: "Calories",
        image: .activeCalorie,
        tint: .activeCalorie,
        unitDefinition: .calorie,
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Resting Calories
    static let restingCalorie = RecordFieldDefinition<UnitEnergy>(
        title: "Calories",
        image: .restingCalorie,
        tint: .restingCalorie,
        unitDefinition: .calorie,
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Protein (macros)
    static let protein = RecordFieldDefinition<UnitMass>(
        title: "Protein",
        image: .protein,
        tint: .protein,
        unitDefinition: .macro,
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Carbs (macros)
    static let carbs = RecordFieldDefinition<UnitMass>(
        title: "Carbohydrates",
        image: .carbs,
        tint: .carbs,
        unitDefinition: .macro,
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Fat (macros)
    static let fat = RecordFieldDefinition<UnitMass>(
        title: "Fat",
        image: .fat,
        tint: .fat,
        unitDefinition: .macro,
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Activity Duration
    static let activity = RecordFieldDefinition<UnitDuration>(
        title: "Duration",
        image: .activeCalorie,
        tint: .activeCalorie,
        unitDefinition: .activity,
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )

    // Alt Activity Duration
    static let duration = RecordFieldDefinition<UnitDuration>(
        title: "Duration",
        image: .duration,
        tint: .duration,
        unitDefinition: .activity,
        validator: { $0 >= 0 },
        formatter: .number.precision(.fractionLength(0))
    )
}
