import SwiftUI

/// Protocol defining UI-specific behavior for health data types.
/// Each health data type implements this to define its visual appearance,
/// form configuration, and display behavior.
protocol HealthRecordUIDefinition {
    // MARK: Associated Types

    /// The type of view returned by formContent
    associatedtype FormContent: View

    /// The type of view returned by rowSubtitle
    associatedtype RowSubtitle: View

    // MARK: Visual Identity

    /// The localized title for this data type
    var title: String.LocalizationValue { get }

    /// The icon representing this data type
    var icon: Image { get }

    /// The primary color for this data type
    var color: Color { get }

    // MARK: Chart Integration

    /// The color to use in charts for this data type
    var chartColor: Color { get }

    /// The preferred number formatter for displaying values
    var preferredFormatter: FloatingPointFormatStyle<Double> { get }

    // MARK: Data Factory

    /// Creates a new instance of the health data type
    func createNew() -> any HealthData

    // MARK: UI Component Builders

    /// Builds the form content for editing/creating records of this type
    @MainActor func formContent<T: HealthData>(_ record: T) -> FormContent

    /// Builds the subtitle content for list rows of this type
    @MainActor func rowSubtitle<T: HealthData>(_ record: T) -> RowSubtitle
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
        case .activity:
            return ActivityRecordUI()
        }
    }

    // MARK: Shared UI Methods

    /// Creates a new record form for this data type
    @MainActor @ViewBuilder
    func createNewRecordForm() -> some View {
        switch self {
        case .weight:
            RecordForm(uiDefinition.title, record: Weight(0), isEditing: false) {
                WeightRecordUI().formContent(Weight(0))
            }
        case .calorie:
            RecordForm(uiDefinition.title, record: DietaryCalorie(0), isEditing: false) {
                CalorieRecordUI().formContent(DietaryCalorie(0))
            }
        case .activity:
            RecordForm(uiDefinition.title, record: ActiveEnergy(0), isEditing: false) {
                ActivityRecordUI().formContent(ActiveEnergy(0))
            }
        }
    }

    /// Creates an edit record form for the given record
    @MainActor @ViewBuilder
    func createEditRecordForm<T: HealthData>(_ record: T) -> some View {
        switch self {
        case .weight:
            if let weight = record as? Weight {
                RecordForm(uiDefinition.title, record: weight, isEditing: true) {
                    WeightRecordUI().formContent(weight)
                }
            } else {
                EmptyView()
            }
        case .calorie:
            if let calorie = record as? DietaryCalorie {
                RecordForm(uiDefinition.title, record: calorie, isEditing: true) {
                    CalorieRecordUI().formContent(calorie)
                }
            } else {
                EmptyView()
            }
        case .activity:
            if let activity = record as? ActiveEnergy {
                RecordForm(uiDefinition.title, record: activity, isEditing: true) {
                    ActivityRecordUI().formContent(activity)
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
        case .activity:
            if let activity = record as? ActiveEnergy {
                ActivityRecordUI().rowSubtitle(activity)
            } else {
                EmptyView()
            }
        }
    }
}
