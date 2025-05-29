import SwiftUI

// MARK: Dietary Energy
// ============================================================================

struct CaloriesRow: View {
    @Binding var calorie: DietaryEnergy

    var body: some View {
        DetailedRow(
            title: Text(String(localized: "Calories")),
            subtitle: calorie.measurement.computedText(
                calorie.calculatedCalories(),
                format: .number.precision(.fractionLength(0))
            ),
            details: nil,
            image: Image.dietaryCalorie, tint: .orange
        ) {
            MeasurementField(
                measurement: calorie.measurement,
                format: .number.precision(.fractionLength(0))
            )
        }
    }
}

// MARK: Calorie Macros
// ============================================================================

struct MacrosProteinRow: View {
    @Binding var calorie: DietaryEnergy

    var body: some View {
        DetailedRow(
            title: Text(String(localized: "Protein")),
            subtitle: calorie.proteinMeasurement.computedText(
                calorie.calculatedProtein(),
                format: .number.precision(.fractionLength(0))
            ),
            details: nil,
            image: Image.protein, tint: .purple
        ) {
            MeasurementField(
                measurement: calorie.proteinMeasurement,
                format: .number.precision(.fractionLength(0))
            )
        }
    }
}

struct MacrosCarbsRow: View {
    @Binding var calorie: DietaryEnergy

    var body: some View {
        DetailedRow(
            title: Text(String(localized: "Carbohydrates")),
            subtitle: calorie.carbsMeasurement.computedText(
                calorie.calculatedCarbs(),
                format: .number.precision(.fractionLength(0))
            ),
            details: nil,
            image: Image.carbs, tint: .green
        ) {
            MeasurementField(
                measurement: calorie.carbsMeasurement,
                format: .number.precision(.fractionLength(0))
            )
        }
    }
}

struct MacrosFatRow: View {
    @Binding var calorie: DietaryEnergy

    var body: some View {
        DetailedRow(
            title: Text(String(localized: "Fat")),
            subtitle: calorie.fatMeasurement.computedText(
                calorie.calculatedFat(),
                format: .number.precision(.fractionLength(0))
            ),
            details: nil,
            image: Image.fat, tint: .yellow
        ) {
            MeasurementField(
                measurement: calorie.fatMeasurement,
                format: .number.precision(.fractionLength(0))
            )
        }
    }
}

// MARK: Active Calories
// ============================================================================

struct RestingCaloriesRow: View {
    @Binding var calorie: RestingEnergy

    var body: some View {
        DetailedRow(
            title: Text(String(localized: "Resting Calories")),
            subtitle: nil, details: nil,
            image: Image.restingCalorie, tint: .purple
        ) {
            MeasurementField(
                measurement: calorie.measurement,
                format: .number.precision(.fractionLength(0))
            )
        }
    }
}

struct BurnedCaloriesRow: View {
    @Binding var calorie: ActiveEnergy

    var body: some View {
        DetailedRow(
            title: Text(String(localized: "Burned Calories")),
            subtitle: nil, details: nil,
            image: Image.calories, tint: .orange
        ) {
            MeasurementField(
                measurement: calorie.measurement,
                format: .number.precision(.fractionLength(0))
            )
        }
    }
}

struct ActivityRow: View {
    @Binding var calorie: ActiveEnergy

    var body: some View {
        DetailedRow(
            title: Text(String(localized: "Activity Duration")),
            subtitle: nil, details: nil,
            image: Image.activeCalorie, tint: .green
        ) {
            MeasurementField(
                measurement: calorie.durationMeasurement,
                format: .number.precision(.fractionLength(0))
            )
        }
    }
}

// MARK: Weight
// ============================================================================

struct WeightRow: View {
    @Binding var weight: Weight

    var body: some View {
        DetailedRow(
            title: Text(String(localized: "Weight")),
            subtitle: nil, details: nil,
            image: Image.weight, tint: .indigo
        ) {
            MeasurementField(
                measurement: weight.measurement,
                format: .number.precision(.fractionLength(0))
            )
        }
    }
}
