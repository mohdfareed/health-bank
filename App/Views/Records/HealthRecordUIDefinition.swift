import SwiftUI

/// Protocol defining UI-specific behavior for health data types.
/// Each health data type implements this to define its visual appearance,
/// form configuration, and display behavior.
protocol HealthRecordUIDefinition {
    // MARK: Associated Types
    associatedtype FormContent: View
    associatedtype RowSubtitle: View
    associatedtype MainValue: View

    // MARK: Visual Identity
    var title: String.LocalizationValue { get }
    var icon: Image { get }
    var color: Color { get }
    var preferredFormatter: FloatingPointFormatStyle<Double> { get }

    // MARK: Data Factory
    func createNew() -> any HealthData

    // MARK: UI Component Builders
    @MainActor func formContent<T: HealthData>(_ record: T) -> FormContent
    @MainActor func rowSubtitle<T: HealthData>(_ record: T) -> RowSubtitle
    @MainActor func mainValue<T: HealthData>(_ record: T) -> MainValue
}

// MARK: UI Integration Extension
// ============================================================================

extension HealthDataModel {
    /// The UI definition for this data type
    var uiDefinition: any HealthRecordUIDefinition {
        switch self {
        case .weight:
            return WeightRecordUI()
        case .calorie:
            return CalorieRecordUI()
        }
    }

    // MARK: Shared UI Methods

    /// Creates a new record form for this data type
    @MainActor @ViewBuilder
    func createNewRecordForm() -> some View {
        switch self {
        case .weight:
            RecordForm(uiDefinition.title, record: Weight(0), isEditing: false) { editableRecord in
                WeightRecordUI().formContent(editableRecord)
            }
        case .calorie:
            RecordForm(uiDefinition.title, record: DietaryCalorie(0), isEditing: false) {
                editableRecord in
                CalorieRecordUI().formContent(editableRecord)
            }
        }
    }

    /// Creates an edit record form for the given record
    @MainActor @ViewBuilder
    func createEditRecordForm<T: HealthData>(_ record: T) -> some View {
        switch self {
        case .weight:
            if let weight = record as? Weight {
                RecordForm(uiDefinition.title, record: weight, isEditing: true) { editableRecord in
                    WeightRecordUI().formContent(editableRecord)
                }
            } else {
                EmptyView()
            }
        case .calorie:
            if let calorie = record as? DietaryCalorie {
                RecordForm(uiDefinition.title, record: calorie, isEditing: true) { editableRecord in
                    CalorieRecordUI().formContent(editableRecord)
                }
            } else {
                EmptyView()
            }
        }
    }

    /// Creates the row subtitle for the given record
    @MainActor @ViewBuilder
    func createRowSubtitle<T: HealthData>(_ record: T) -> some View {
        switch self {
        case .weight:
            if let weight = record as? Weight {
                WeightRecordUI().rowSubtitle(weight)
            } else {
                EmptyView()
            }
        case .calorie:
            if let calorie = record as? DietaryCalorie {
                CalorieRecordUI().rowSubtitle(calorie)
            } else {
                EmptyView()
            }
        }
    }

    /// Creates the main value display for the given record
    @MainActor @ViewBuilder
    func createMainValue<T: HealthData>(_ record: T) -> some View {
        switch self {
        case .weight:
            if let weight = record as? Weight {
                WeightRecordUI().mainValue(weight)
            } else {
                EmptyView()
            }
        case .calorie:
            if let calorie = record as? DietaryCalorie {
                CalorieRecordUI().mainValue(calorie)
            } else {
                EmptyView()
            }
        }
    }
}
