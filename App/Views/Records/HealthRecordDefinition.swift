import SwiftUI

extension HealthDataModel {
    @MainActor var definition: HealthRecordDefinition {
        switch self {
        case .weight:
            return weightRecordDefinition
        case .calorie:
            return calorieRecordDefinition
        }
    }

    @MainActor @ViewBuilder var recordList: some View {
        switch self {
        case .weight:
            RecordList(.weight, for: Weight.self)
        case .calorie:
            RecordList(.calorie, for: DietaryCalorie.self)
        }
    }
}

// MARK: Record Row Definition
// ============================================================================

/// Definition for a record field in health data types.
struct RecordRowDefinition {
    let title: String.LocalizationValue
    let icon: Image
    let tint: Color

    let unitDefinition: AnyUnitDefinition
    let formatter: FloatingPointFormatStyle<Double>
    let validator: (@Sendable (Double) -> Bool)?

    @MainActor func measurement(
        _ binding: Binding<Double?>
    ) -> LocalizedMeasurement<Dimension> {
        .init(binding, definition: unitDefinition.unit)
    }
}

// MARK: Health Record Definition
// ============================================================================

/// Definition of UI-specific behavior for health data types.
/// Each health data type creates this to define its visual appearance,
/// form configuration, and display behavior.
@MainActor
struct HealthRecordDefinition {
    let title: String.LocalizationValue
    let icon: Image
    let color: Color

    let fields: [RecordRowDefinition]
    let formView: (Binding<any HealthData>) -> AnyView
    let rowView: (any HealthData) -> AnyView

    init<Data: HealthData, FormContent: View, RowContent: View>(
        title: String.LocalizationValue, icon: Image, color: Color,
        fields: [RecordRowDefinition],
        @ViewBuilder form: @escaping (Binding<Data>) -> FormContent,
        @ViewBuilder row: @escaping (Data) -> RowContent
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.fields = fields

        self.formView = { binding in
            let typedBinding = Binding<Data>(
                get: { binding.wrappedValue as! Data },
                set: { binding.wrappedValue = $0 }
            )
            return AnyView(form(typedBinding))
        }
        self.rowView = { record in AnyView(row(record as! Data)) }
    }
}

// MARK: Extensions
// ============================================================================

protocol AnyUnitDefinitionProtocol {
    var unit: UnitDefinition<Dimension> { get }
}

// Type erased unit definition that can be used in SwiftUI views.
struct AnyUnitDefinition: AnyUnitDefinitionProtocol {
    let unit: UnitDefinition<Dimension>
    init<Unit: Dimension>(_ unit: UnitDefinition<Unit>) {
        self.unit = unit as! UnitDefinition<Dimension>
    }
}
