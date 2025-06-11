import SwiftUI

/// Definition for a record field in health data types.
struct RecordRowDefinition<Unit: Dimension>: Sendable {
    let title: String.LocalizationValue
    let image: Image
    let tint: Color

    let unitDefinition: UnitDefinition<Unit>
    let formatter: FloatingPointFormatStyle<Double>
    let validator: (@Sendable (Double) -> Bool)?

    @MainActor func measurement(
        _ binding: Binding<Double?>
    ) -> LocalizedMeasurement<Unit> {
        .init(binding, definition: unitDefinition)
    }
}

/// Definition of UI-specific behavior for health data types.
/// Each health data type creates this to define its visual appearance,
/// form configuration, and display behavior.
struct HealthRecordDefinition<
    T: HealthData, FormContent: View, RowContent: View
> {
    // MARK: Visual Identity
    let title: String.LocalizationValue
    let icon: Image
    let color: Color

    // MARK: UI Component Builders
    let fields: [RecordRowDefinition<Dimension>]
    @ViewBuilder let formContent: (T) -> FormContent
    @ViewBuilder let rowContent: (T) -> RowContent
}

// MARK: Extensions

extension HealthDataModel {
    /// Returns the UI definition for this health data model.
    var definition: HealthRecordDefinition<T, AnyView, AnyView> {
        switch self {
        case .calorie:
            return CalorieRecordUI() as! HealthRecordDefinition<T, AnyView, AnyView>
        case .weight:
            return WeightRecordUI() as! HealthRecordDefinition<T, AnyView, AnyView>
        }
    }
}
