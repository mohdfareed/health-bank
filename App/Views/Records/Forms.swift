import SwiftData
import SwiftUI

struct RecordFormDefinition<
    R: HealthDate, C: View
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
                    FieldDefinition.weight,
                    value: $weight.weight.optional(0),
                    isInternal: weight.isInternal,
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
                        isInternal: calorie.isInternal,
                        computed: calorie.calculatedCalories
                    )
                    RecordField(
                        FieldDefinition.protein,
                        value: macros.protein,
                        isInternal: calorie.isInternal,
                        computed: calorie.calculatedProtein
                    )
                    RecordField(
                        FieldDefinition.carbs,
                        value: macros.carbs,
                        isInternal: calorie.isInternal,
                        computed: calorie.calculatedCarbs
                    )
                    RecordField(
                        FieldDefinition.fat,
                        value: macros.fat,
                        isInternal: calorie.isInternal,
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
                        isInternal: calorie.isInternal,
                    )
                    RecordField(
                        FieldDefinition.duration,
                        value: $calorie.duration,
                        isInternal: calorie.isInternal, showPicker: true,
                    )

                    Picker(selection: $calorie.workout) {
                        ForEach(
                            WorkoutActivity.allCases, id: \.self
                        ) { activity in
                            Label {
                                Text(activity.localized)
                            } icon: {
                                activity.icon
                            }.tag(activity)
                        }

                        Divider()
                        Text("Other").tag(nil as WorkoutActivity?)
                    } label: {
                        Label {
                            Text("Activity")
                        } icon: {
                            Image.activeCalorie
                                .foregroundStyle(Color.activeCalorie)
                        }
                    }
                    .disabled(!calorie.isInternal)
                    .contentTransition(
                        .symbolEffect(.replace)
                    )
                    .frame(maxHeight: 8)
                }
            )
        }
    )
}
