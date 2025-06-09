import Foundation
import SwiftUI

/// Simple field definition that works with RecordField component
struct RecordFieldDefinition<Unit: Dimension>: Sendable {
    let validator: (@Sendable (Double) -> Bool)?
    let formatter: FloatingPointFormatStyle<Double>
    let image: Image
    let tint: Color
    let title: String.LocalizationValue
    let unitDefinition: UnitDefinition<Unit>

    init(
        unitDefinition: UnitDefinition<Unit>,
        validator: (@Sendable (Double) -> Bool)? = nil,
        formatter: FloatingPointFormatStyle<Double>,
        image: Image,
        tint: Color,
        title: String.LocalizationValue
    ) {
        self.unitDefinition = unitDefinition
        self.validator = validator
        self.formatter = formatter
        self.image = image
        self.tint = tint
        self.title = title
    }

    @MainActor
    func measurement(_ binding: Binding<Double?>) -> LocalizedMeasurement<Unit> {
        LocalizedMeasurement(binding, definition: unitDefinition)
    }
}

// MARK: Predefined Field Definitions
// ============================================================================

extension RecordFieldDefinition where Unit == UnitEnergy {
    static let calorie = RecordFieldDefinition(
        unitDefinition: .calorie,
        validator: { $0 > 0 && $0 <= 10000 },
        formatter: .number.precision(.fractionLength(0)),
        image: .calories,
        tint: .calories,
        title: "Calories"
    )
}

extension RecordFieldDefinition where Unit == UnitMass {
    static let protein = RecordFieldDefinition(
        unitDefinition: .macro,
        validator: { $0 >= 0 && $0 <= 1000 },
        formatter: .number.precision(.fractionLength(0)),
        image: .protein,
        tint: .protein,
        title: "Protein"
    )

    static let carbs = RecordFieldDefinition(
        unitDefinition: .macro,
        validator: { $0 >= 0 && $0 <= 1000 },
        formatter: .number.precision(.fractionLength(0)),
        image: .carbs,
        tint: .carbs,
        title: "Carbs"
    )

    static let fat = RecordFieldDefinition(
        unitDefinition: .macro,
        validator: { $0 >= 0 && $0 <= 1000 },
        formatter: .number.precision(.fractionLength(0)),
        image: .fat,
        tint: .fat,
        title: "Fat"
    )

    static let weight = RecordFieldDefinition(
        unitDefinition: .weight,
        validator: { $0 > 0 },
        formatter: .number.precision(.fractionLength(1)),
        image: .weight,
        tint: .weight,
        title: "Weight"
    )
}
