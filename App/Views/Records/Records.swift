import SwiftUI

struct RecordRowDefinition<R, U>: Sendable where R: HealthRecord, U: Dimension {
    let field: RecordFieldDefinition<U>
    let property: @Sendable (R) -> Double?

    @ViewBuilder let subtitle: @MainActor @Sendable (R) -> AnyView?
    @ViewBuilder let destination: @MainActor @Sendable (R) -> AnyView

    @MainActor @ViewBuilder
    func recordRow(_ record: R) -> some View {
        RecordRow(
            record: record, field: field,
            measurement: field.measurement(.constant(property(record))),
            subtitle: { subtitle(record) }
        ) {
            destination(record)
        }
    }
}

// MARK: Record Definitions
// ============================================================================

/// Record definitions that centralize RecordRow components for each record.
enum RecordDefinition {
    static let weight = RecordRowDefinition<Weight, UnitMass>(
        field: FieldDefinition.weight,
        property: { $0.weight },
        subtitle: { _ in AnyView(EmptyView()) },
        destination: { weight in
            AnyView(
                RecordForm("Weight", editing: weight) {
                    FormDefinition.weight.content(weight)
                }
            )
        }
    )

    static let dietary = RecordRowDefinition<DietaryCalorie, UnitEnergy>(
        field: FieldDefinition.dietaryCalorie,
        property: { $0.calories },
        subtitle: {
            let calorie = $0
            let macros = calorie.macros ?? .init()
            let protein = FieldDefinition.protein.measurement(
                .constant(macros.protein)
            )
            let carbs = FieldDefinition.carbs.measurement(
                .constant(macros.carbs)
            )
            let fat = FieldDefinition.fat.measurement(
                .constant(macros.fat)
            )

            AnyView(
                HStack(alignment: .bottom, spacing: 0) {
                    if calorie.macros?.protein != nil {
                        ValueView(
                            measurement: protein,
                            icon: .protein, tint: .protein,
                            format: FieldDefinition.protein.formatter
                        )
                        Spacer().frame(maxWidth: 8)
                    }
                    if calorie.macros?.carbs != nil {
                        ValueView(
                            measurement: carbs,
                            icon: .carbs, tint: .carbs,
                            format: FieldDefinition.carbs.formatter
                        )
                        Spacer().frame(maxWidth: 8)
                    }
                    if calorie.macros?.fat != nil {
                        ValueView(
                            measurement: fat,
                            icon: .fat, tint: .fat,
                            format: FieldDefinition.fat.formatter
                        )
                        Spacer().frame(maxWidth: 8)
                    }
                }
            )
        },
        destination: { calorie in
            AnyView(
                RecordForm("Calories", editing: calorie) {
                    FormDefinition.dietaryCalorie.content(calorie)
                }
            )
        }
    )

    static func active(
        workout: WorkoutActivity?
    ) -> RecordRowDefinition<ActiveEnergy, UnitEnergy> {
        .init(
            field: FieldDefinition.activityCalorie(workout: workout),
            property: { $0.calories },
            subtitle: {
                let calorie = $0
                let duration = FieldDefinition.activity.measurement(
                    .constant(calorie.duration)
                )

                AnyView(
                    HStack(alignment: .bottom, spacing: 0) {
                        if calorie.duration != nil {
                            ValueView(
                                measurement: duration,
                                icon: .duration, tint: .duration,
                                format: FieldDefinition.activity.formatter
                            )
                            Spacer().frame(maxWidth: 8)
                        }
                    }
                )
            },
            destination: { active in
                AnyView(
                    RecordForm("Activity", editing: active) {
                        FormDefinition.activeEnergy.content(active)
                    }
                )
            }
        )
    }

    static let resting = RecordRowDefinition<RestingEnergy, UnitEnergy>(
        field: FieldDefinition.calorie,
        property: { $0.calories },
        subtitle: { _ in AnyView(EmptyView()) },
        destination: { resting in
            AnyView(
                RecordForm(
                    "Resting Energy", editing: resting
                ) {
                    FormDefinition.restingEnergy.content(resting)
                }
            )
        }
    )
}
