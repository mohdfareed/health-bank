import Foundation
import SwiftUI

// MARK: - Field Definitions

let proteinRowDefinition = RecordRowDefinition(
    title: "Protein", icon: .protein, tint: .protein,
    unitDefinition: .init(.macro),
    formatter: .number.precision(.fractionLength(0)),
    validator: { $0 >= 0 }
)

let carbsRowDefinition = RecordRowDefinition(
    title: "Carbs", icon: .carbs, tint: .carbs,
    unitDefinition: .init(.macro),
    formatter: .number.precision(.fractionLength(0)),
    validator: { $0 >= 0 }
)

let fatRowDefinition = RecordRowDefinition(
    title: "Fat", icon: .fat, tint: .fat,
    unitDefinition: .init(.macro),
    formatter: .number.precision(.fractionLength(0)),
    validator: { $0 >= 0 }
)

let alcoholRowDefinition = RecordRowDefinition(
    title: "Alcohol", icon: .alcohol, tint: .alcohol,
    unitDefinition: .init(.macro),
    formatter: .number.precision(.fractionLength(0)),
    validator: { $0 >= 0 }
)

// // Helper view for macro values in row subtitle
// struct MacroValueView: View {
//     let value: Double
//     let icon: Image
//     let tint: Color
//     @LocalizedMeasurement var measurement: Measurement

//     init(value: Double, icon: Image, tint: Color) {
//         self.value = value
//         self.icon = icon
//         self.tint = tint
//         self._measurement = LocalizedMeasurement(.constant(value), definition: .init(.macro))
//     }

//     var body: some View {
//         ValueView(
//             measurement: $measurement,
//             icon: icon, tint: tint,
//             format: .number.precision(.fractionLength(0))
//         )
//         .textScale(.secondary)
//         .imageScale(.small)
//         .symbolVariant(.fill)
//     }
// }

// // Helper view for alcohol values in row subtitle
// struct AlcoholValueView: View {
//     let value: Double
//     let icon: Image
//     let tint: Color
//     @LocalizedMeasurement var measurement: Measurement<UnitVolume>

//     init(value: Double, icon: Image, tint: Color) {
//         self.value = value
//         self.icon = icon
//         self.tint = tint
//         self._measurement = LocalizedMeasurement(.constant(value), definition: .alcohol)
//     }

//     var body: some View {
//         ValueView(
//             measurement: $measurement,
//             icon: icon, tint: tint,
//             format: .number.precision(.fractionLength(0))
//         )
//         .textScale(.secondary)
//         .imageScale(.small)
//         .symbolVariant(.fill)
//     }
// }
