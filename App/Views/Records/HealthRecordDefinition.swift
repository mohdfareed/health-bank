import SwiftUI

extension HealthDataModel {
    /// Returns the UI definition for a specific health data type.
    /// This is used to create the visual representation and form for the data.
    @MainActor var definition: HealthRecordDefined {
        switch self {
        case .weight:
            return weightRecordDefinition
        case .calorie:
            return weightRecordDefinition
        }
    }
}

// MARK: Record Row Definition
// ============================================================================

protocol RecordRowDefined: Sendable {
    var title: String.LocalizationValue { get }
    var icon: Image { get }
    var tint: Color { get }

    var unitDefinition: AnyUnitDefinition { get }
    var formatter: FloatingPointFormatStyle<Double> { get }
    var validator: (@Sendable (Double) -> Bool)? { get }

    @MainActor func measurement(
        _ binding: Binding<Double?>
    ) -> LocalizedMeasurement<Dimension>
}

/// Definition for a record field in health data types.
struct RecordRowDefinition: RecordRowDefined {
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

protocol HealthRecordDefined: Sendable {
    var title: String.LocalizationValue { get }
    var icon: Image { get }
    var color: Color { get }
    var fields: [AnyRecordRowDefinition] { get }

    @MainActor func formView(binding: Binding<any HealthData>) -> AnyView
    @MainActor func rowView(for record: any HealthData) -> AnyView
}

/// Definition of UI-specific behavior for health data types.
/// Each health data type creates this to define its visual appearance,
/// form configuration, and display behavior.
@MainActor
struct HealthRecordDefinition<Data: HealthData>: HealthRecordDefined {
    // MARK: Visual Identity
    let title: String.LocalizationValue
    let icon: Image
    let color: Color
    let fields: [AnyRecordRowDefinition]

    private let _form: (Binding<Data>) -> AnyView
    private let _row: (Data) -> AnyView

    init<FormContent: View, RowContent: View>(
        title: String.LocalizationValue, icon: Image, color: Color,
        fields: [RecordRowDefined],
        @ViewBuilder form: @escaping (Binding<Data>) -> FormContent,
        @ViewBuilder row: @escaping (Data) -> RowContent
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.fields = fields.map { AnyRecordRowDefinition($0) }
        self._form = { binding in AnyView(form(binding)) }
        self._row = { record in AnyView(row(record)) }
    }

    func formView(binding: Binding<any HealthData>) -> AnyView {
        if let data = binding.wrappedValue as? Data {
            return _form(Binding<Data>(get: { data }, set: { _ in }))
        }
        return AnyView(EmptyView())
    }

    func rowView(for record: any HealthData) -> AnyView {
        if let data = record as? Data {
            return _row(data)
        }
        return AnyView(EmptyView())
    }
}

// MARK: Extensions
// ============================================================================

struct AnyRecordRowDefinition: RecordRowDefined {
    let base: RecordRowDefined
    var title: String.LocalizationValue
    var icon: Image
    var tint: Color
    var unitDefinition: AnyUnitDefinition
    var formatter: FloatingPointFormatStyle<Double>
    var validator: (@Sendable (Double) -> Bool)?

    init<R: RecordRowDefined>(_ base: R) {
        self.base = base
        self.title = base.title
        self.icon = base.icon
        self.tint = base.tint
        self.unitDefinition = base.unitDefinition
        self.formatter = base.formatter
        self.validator = base.validator
    }

    @MainActor func measurement(
        _ binding: Binding<Double?>
    ) -> LocalizedMeasurement<Dimension> {
        base.measurement(binding)
    }
}

// struct AnyRecordDefinition: Sendable {
//     let title: String.LocalizationValue
//     let icon: Image
//     let color: Color
//     let fields: [AnyRecordRowDefinition]

//     init<Data: HealthData>(_ base: HealthRecordDefinition<Data>) {
//         self.title = base.title
//         self.icon = base.icon
//         self.color = base.color
//         self.fields = base.fields.map { AnyRecordRowDefinition($0) }
//     }

//     func formView(binding: Binding<HealthDataModel>) -> AnyView {
//         _form(binding)
//     }

//     func rowView(for record: HealthDataModel) -> AnyView {
//         _row(record)
//     }
// }
