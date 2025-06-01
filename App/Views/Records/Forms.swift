import SwiftData
import SwiftUI

struct RecordFormDefinition<
    R: HealthRecord & PersistentModel, C: View
>: Sendable {
    @ViewBuilder var content: @MainActor (R) -> C
}

// MARK: Form Definitions
// ============================================================================

/// Form definitions that centralize form configurations for each record type.
enum FormDefinition {
    static let weight = RecordFormDefinition<Weight, AnyView>(
        content: {
            @Bindable var weight = $0
            AnyView(
                RecordField(
                    FieldDefinition.dietaryCalorie,
                    value: $weight.weight.optional(0),
                    source: weight.source,
                )
            )
        }
    )

    static let dietaryCalorie = RecordFormDefinition<DietaryCalorie, AnyView>(
        content: {
            @Bindable var calorie = $0
            let macros = $calorie.macros.defaulted(to: .init())

            AnyView(
                Group {
                    RecordField(
                        FieldDefinition.calorie,
                        value: $calorie.calories.optional(0),
                        source: calorie.source,
                        computed: calorie.calculatedCalories
                    )
                    RecordField(
                        FieldDefinition.protein,
                        value: macros.protein,
                        source: calorie.source,
                        computed: calorie.calculatedProtein
                    )
                    RecordField(
                        FieldDefinition.carbs,
                        value: macros.carbs,
                        source: calorie.source,
                        computed: calorie.calculatedCarbs
                    )
                    RecordField(
                        FieldDefinition.fat,
                        value: macros.fat,
                        source: calorie.source,
                        computed: calorie.calculatedFat
                    )
                }
            )
        }
    )

    static let activeEnergy = RecordFormDefinition<ActiveEnergy, AnyView>(
        content: {
            @Bindable var calorie = $0
            AnyView(
                List {
                    RecordField(
                        FieldDefinition.calorie,
                        value: $calorie.calories.optional(0),
                        source: calorie.source,
                    )
                    RecordField(
                        FieldDefinition.activity,
                        value: $calorie.duration,
                        source: calorie.source, showPicker: true,
                    )
                    Picker(selection: $calorie.workout) {
                        ForEach(WorkoutActivity.allCases, id: \.self) {
                            Text($0.localized).tag($0)
                        }
                    } label: {
                        Text("Activity")
                    }
                }
            )
        }
    )

    static let restingEnergy = RecordFormDefinition<RestingEnergy, AnyView>(
        content: {
            @Bindable var calorie = $0
            AnyView(
                RecordField(
                    FieldDefinition.calorie,
                    value: $calorie.calories.optional(0),
                    source: calorie.source,
                )
            )
        }
    )
}
