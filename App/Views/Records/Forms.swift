import SwiftData
import SwiftUI

struct RecordFormDefinition<
    R: HealthRecord, C: View
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
                        FieldDefinition.duration,
                        value: $calorie.duration,
                        source: calorie.source, showPicker: true,
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
                        Text("No Activity").tag(nil as WorkoutActivity?)
                    } label: {
                        Label {
                            Text("Activity")
                        } icon: {
                            Image.activeCalorie
                                .foregroundStyle(Color.activeCalorie)
                        }
                    }
                    .contentTransition(
                        .symbolEffect(.replace)
                    )
                    .frame(maxHeight: 8)
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
