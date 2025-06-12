import SwiftUI

let weightRowDefinition = RecordRowDefinition(
    title: "Weight", icon: .weight, tint: .weight,
    unitDefinition: .init(.weight),
    formatter: .number.precision(.fractionLength(1)),
    validator: { $0 > 0 },
)

@MainActor let weightRecordDefinition = HealthRecordDefinition(
    title: "Weight", icon: .weight, color: .weight,
    fields: [
        weightRowDefinition
    ],
) { weight in
    RecordRow(
        weightRowDefinition,
        value: weight.weight.optional(0),
        isInternal: weight.wrappedValue.source == .app,
        showPicker: true
    )
} row: { (weight: Weight) in
    ValueView(
        measurement: .init(
            baseValue: .constant(weight.weight),
            definition: .weight
        ),
        icon: nil, tint: nil,
        format: weightRowDefinition.formatter
    )
}
