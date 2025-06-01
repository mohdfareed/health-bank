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
            AnyView(WeightForm(weight: weight))
        }
    )

    static let dietary = RecordRowDefinition<DietaryCalorie, UnitEnergy>(
        field: FieldDefinition.dietaryCalorie,
        property: { $0.calories },
        subtitle: {
            @Bindable var calorie = $0
            let macros = $calorie.macros.defaulted(to: .init())

            let protein = FieldDefinition.protein.measurement(
                macros.protein
            )
            let carbs = FieldDefinition.carbs.measurement(
                macros.carbs
            )
            let fat = FieldDefinition.fat.measurement(
                macros.fat
            )

            AnyView(
                HStack(alignment: .bottom, spacing: 0) {
                    if calorie.macros?.protein != nil {
                        ValueView(
                            measurement: protein, icon: .protein,
                            format: FieldDefinition.protein.formatter
                        )
                        Spacer().frame(maxWidth: 8)
                    }
                    if calorie.macros?.carbs != nil {
                        ValueView(
                            measurement: carbs, icon: .carbs,
                            format: FieldDefinition.carbs.formatter
                        )
                        Spacer().frame(maxWidth: 8)
                    }
                    if calorie.macros?.fat != nil {
                        ValueView(
                            measurement: fat, icon: .fat,
                            format: FieldDefinition.fat.formatter
                        )
                        Spacer().frame(maxWidth: 8)
                    }
                }
            )
        },
        destination: { calorie in
            AnyView(DietaryCalorieForm(calorie: calorie))
        }
    )

    static let active = RecordRowDefinition<ActiveEnergy, UnitEnergy>(
        field: FieldDefinition.activeCalorie,
        property: { $0.calories },
        subtitle: {
            @Bindable var calorie = $0
            let duration = FieldDefinition.activity.measurement(
                $calorie.duration
            )

            AnyView(
                Group {
                    if calorie.duration != nil {
                        ValueView(
                            measurement: duration, icon: .duration,
                            format: FieldDefinition.activity.formatter
                        )
                    }
                }
            )
        },
        destination: { active in
            AnyView(ActiveEnergyForm(activeEnergy: active))
        }
    )

    static let resting = RecordRowDefinition<RestingEnergy, UnitEnergy>(
        field: FieldDefinition.restingCalorie,
        property: { $0.calories },
        subtitle: { _ in AnyView(EmptyView()) },
        destination: { resting in
            AnyView(RestingEnergyForm(restingEnergy: resting))
        }
    )
}
