import Foundation
import SwiftUI

/// UI definition for DietaryCalorie health data type
struct CalorieRecordUI: HealthRecordUIDefinition {
    // MARK: Associated Types

    typealias FormContent = AnyView
    typealias RowSubtitle = AnyView
    typealias MainValue = AnyView

    // MARK: Visual Identity

    var title: String.LocalizationValue { "Food" }
    var icon: Image { .dietaryCalorie }
    var color: Color { .dietaryCalorie }

    // MARK: Chart Integration

    var chartColor: Color { .dietaryCalorie }
    var preferredFormatter: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(0))
    }

    // MARK: Data Factory

    func createNew() -> any HealthData {
        DietaryCalorie(0)
    }

    // MARK: Field Definitions

    /// Field definitions specific to calorie records
    enum Fields {
        static let calorie = RecordFieldDefinition(
            unitDefinition: .calorie,
            validator: { $0 >= 0 },
            formatter: .number.precision(.fractionLength(0)),
            image: .calories,
            tint: .dietaryCalorie,
            title: "Calories"
        )

        static let protein = RecordFieldDefinition(
            unitDefinition: .macro,
            validator: { $0 >= 0 },
            formatter: .number.precision(.fractionLength(0)),
            image: .protein,
            tint: .protein,
            title: "Protein"
        )

        static let carbs = RecordFieldDefinition(
            unitDefinition: .macro,
            validator: { $0 >= 0 },
            formatter: .number.precision(.fractionLength(0)),
            image: .carbs,
            tint: .carbs,
            title: "Carbs"
        )

        static let fat = RecordFieldDefinition(
            unitDefinition: .macro,
            validator: { $0 >= 0 },
            formatter: .number.precision(.fractionLength(0)),
            image: .fat,
            tint: .fat,
            title: "Fat"
        )

        static let alcohol = RecordFieldDefinition(
            unitDefinition: .alcohol,
            validator: { $0 >= 0 },
            formatter: .number.precision(.fractionLength(0)),
            image: .alcohol,
            tint: .alcohol,
            title: "Alcohol"
        )
    }

    // MARK: UI Component Builders

    @MainActor
    func formContent<T: HealthData>(_ record: T) -> FormContent {
        if let calorie = record as? DietaryCalorie {
            let bindableCalorie = Bindable(calorie)
            return AnyView(
                CalorieMeasurementField(calorie: bindableCalorie, uiDefinition: self)
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    @MainActor
    func rowSubtitle<T: HealthData>(_ record: T) -> RowSubtitle {
        if let calorie = record as? DietaryCalorie {
            let macros = calorie.macros ?? .init()
            return AnyView(
                HStack(alignment: .bottom, spacing: 0) {
                    if calorie.macros?.protein != nil {
                        MacroValueView(
                            value: macros.protein ?? 0,
                            icon: .protein, tint: .protein
                        )
                        Spacer().frame(maxWidth: 8)
                    }
                    if calorie.macros?.carbs != nil {
                        MacroValueView(
                            value: macros.carbs ?? 0,
                            icon: .carbs, tint: .carbs
                        )
                        Spacer().frame(maxWidth: 8)
                    }
                    if calorie.macros?.fat != nil {
                        MacroValueView(
                            value: macros.fat ?? 0,
                            icon: .fat, tint: .fat
                        )
                        Spacer().frame(maxWidth: 8)
                    }
                    if calorie.alcohol != nil {
                        MacroValueView(
                            value: calorie.alcohol ?? 0,
                            icon: .alcohol, tint: .alcohol
                        )
                        Spacer().frame(maxWidth: 8)
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    @MainActor
    func mainValue<T: HealthData>(_ record: T) -> MainValue {
        if let calorie = record as? DietaryCalorie {
            let measurement = Measurement(value: calorie.calories, unit: UnitEnergy.kilocalories)

            return AnyView(
                ValueView(
                    measurement: measurement,
                    icon: nil, tint: nil,
                    format: preferredFormatter
                )
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

// Helper view for macro values in row subtitle
struct MacroValueView: View {
    let value: Double
    let icon: Image
    let tint: Color
    @LocalizedMeasurement var measurement: Measurement<UnitMass>

    init(value: Double, icon: Image, tint: Color) {
        self.value = value
        self.icon = icon
        self.tint = tint
        self._measurement = LocalizedMeasurement(.constant(value), definition: .macro)
    }

    var body: some View {
        ValueView(
            measurement: measurement,
            icon: icon, tint: tint,
            format: .number.precision(.fractionLength(0))
        )
        .textScale(.secondary)
        .imageScale(.small)
    }
}

struct CalorieMeasurementField: View {
    @Bindable var calorie: DietaryCalorie
    let uiDefinition: CalorieRecordUI

    init(calorie: Bindable<DietaryCalorie>, uiDefinition: CalorieRecordUI) {
        self.uiDefinition = uiDefinition
        _calorie = calorie
    }

    var body: some View {
        Group {
            // Calories field
            RecordField(
                CalorieRecordUI.Fields.calorie,
                value: $calorie.calories.optional(0),
                isInternal: calorie.source == .app,
                computed: {
                    calorie.calculatedCalories()
                }
            )

            // Protein field
            RecordField(
                CalorieRecordUI.Fields.protein,
                value: macrosBinding.protein,
                isInternal: calorie.source == .app,
                computed: {
                    calorie.calculatedProtein()
                }
            )

            // Carbs field
            RecordField(
                CalorieRecordUI.Fields.carbs,
                value: macrosBinding.carbs,
                isInternal: calorie.source == .app,
                computed: {
                    calorie.calculatedCarbs()
                }
            )

            // Fat field
            RecordField(
                CalorieRecordUI.Fields.fat,
                value: macrosBinding.fat,
                isInternal: calorie.source == .app,
                computed: {
                    calorie.calculatedFat()
                }
            )

            // Alcohol field
            RecordField(
                CalorieRecordUI.Fields.alcohol,
                value: $calorie.alcohol,
                isInternal: calorie.source == .app,
                computed: {
                    calorie.calculatedAlcohol()
                }
            )
        }
    }

    private var macrosBinding:
        (protein: Binding<Double?>, carbs: Binding<Double?>, fat: Binding<Double?>)
    {
        let macros = $calorie.macros.defaulted(to: .init())
        return (
            protein: macros.protein,
            carbs: macros.carbs,
            fat: macros.fat
        )
    }
}
