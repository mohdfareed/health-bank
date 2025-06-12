import Foundation
import SwiftUI

// MARK: - Field Definitions

let calorieRowDefinition = RecordRowDefinition(
    title: "Calories", icon: .calories, tint: .calories,
    unitDefinition: .init(.calorie),
    formatter: .number.precision(.fractionLength(0)),
    validator: { $0 >= 0 }
)

@MainActor
let calorieRecordDefinition = HealthRecordDefinition(
    title: "Calories", icon: .calories, color: .calories,
    fields: [
        calorieRowDefinition
    ],
) { calorie in
    RecordRow(
        calorieRowDefinition,
        value: calorie.calories.optional(0),
        isInternal: calorie.wrappedValue.source == .app,
        showPicker: true
    )
} row: { (calorie: DietaryCalorie) in
    ValueView(
        measurement: .init(
            baseValue: .constant(calorie.calories),
            definition: .calorie
        ),
        icon: nil, tint: nil,
        format: calorieRowDefinition.formatter
    )
}

// extension HealthRecordDefinition where T == DietaryCalorie {
//     /// Returns the UI definition for DietaryCalorie health data type.
//     static func calories() -> HealthRecordDefinition {
//         .init(
//             title: "Calories", icon: .calories, color: .calories,
//             fields: [
//                 .init(calorieRowDefinition),
//                 .init(proteinRecordDefinition),
//                 .init(carbsRecordDefinition),
//                 .init(fatRecordDefinition),
//                 .init(alcoholRecordDefinition),
//             ],
//             formContent: { calorie in
//                 let calories = Bindable(calorie)
//                 let macros = calories.macros.defaulted(to: .init())

//                 RecordRow(
//                     calorieRowDefinition,
//                     value: calories.calories.optional(0),
//                     isInternal: calorie.source == .app,
//                     computed: {
//                         calorie.calculatedCalories()
//                     }
//                 )
//             },
//             rowContent: { calorie in
//                 DetailedRow(image: nil, tint: nil) {
//                     ValueView(
//                         measurement: .init(
//                             baseValue: .constant(calorie.calories),
//                             definition: .calorie
//                         ),
//                         icon: nil, tint: nil,
//                         format: calorieRowDefinition.formatter
//                     )
//                 } subtitle: {
//                     Text(calorieRowDefinition.unitDefinition)
//                 } details: {
//                     HStack(spacing: 6) {
//                         MacroValueView(
//                             value: calorie.calculatedProtein(),
//                             icon: .protein, tint: .protein
//                         )
//                         MacroValueView(
//                             value: calorie.calculatedCarbs(),
//                             icon: .carbs, tint: .carbs
//                         )
//                         MacroValueView(
//                             value: calorie.calculatedFat(),
//                             icon: .fat, tint: .fat
//                         )
//                         AlcoholValueView(
//                             value: calorie.calculatedAlcohol(),
//                             icon: .alcohol, tint: .alcohol
//                         )
//                     }
//                 }
//             }
//         )
//     }
// }

// // Helper view for macro values in row subtitle
// struct MacroValueView: View {
//     let value: Double
//     let icon: Image
//     let tint: Color
//     @LocalizedMeasurement var measurement: Measurement<UnitMass>

//     init(value: Double, icon: Image, tint: Color) {
//         self.value = value
//         self.icon = icon
//         self.tint = tint
//         self._measurement = LocalizedMeasurement(.constant(value), definition: .macro)
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

// struct CalorieMeasurementField: View {
//     @Bindable var calorie: DietaryCalorie

//     init(calorie: Bindable<DietaryCalorie>) {
//         _calorie = calorie
//     }

//     var body: some View {
//         let macros = $calorie.macros.defaulted(to: .init())
//         Group {
//             // Calories field
//             RecordRow(
//                 calorieRowDefinition,
//                 value: $calorie.calories.optional(0),
//                 isInternal: calorie.source == .app,
//                 computed: {
//                     calorie.calculatedCalories()
//                 }
//             )

//             // Protein field
//             RecordRow(
//                 proteinRecordDefinition,
//                 value: macros.protein,
//                 isInternal: calorie.source == .app,
//                 computed: {
//                     calorie.calculatedProtein()
//                 }
//             )

//             // Carbs field
//             RecordRow(
//                 carbsRecordDefinition,
//                 value: macros.carbs,
//                 isInternal: calorie.source == .app,
//                 computed: {
//                     calorie.calculatedCarbs()
//                 }
//             )

//             // Fat field
//             RecordRow(
//                 fatRecordDefinition,
//                 value: macros.fat,
//                 isInternal: calorie.source == .app,
//                 computed: {
//                     calorie.calculatedFat()
//                 }
//             )

//             // Alcohol field
//             RecordRow(
//                 alcoholRecordDefinition,
//                 value: $calorie.alcohol,
//                 isInternal: calorie.source == .app,
//                 showPicker: true,
//                 computed: {
//                     calorie.calculatedAlcohol()
//                 }
//             )
//         }
//     }
// }
