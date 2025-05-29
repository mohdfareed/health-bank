import SwiftUI

// FIXME: must not rely on type directly like DietaryEnergy
// This is done to reuse it with calorie budgets and goals

// MARK: Dietary Energy
// ============================================================================

struct CaloriesRow: View {
    @Binding var calorie: DietaryEnergy

    var body: some View {
        MeasurementRow(
            measurement: calorie.measurement,
            title: "Calorie", image: Image.dietaryCalorie, tint: .orange,
            computed: calorie.calculatedCalories(),
            format: .number.precision(.fractionLength(0)),
        )
    }
}

// MARK: Calorie Macros
// ============================================================================

struct MacrosProteinRow: View {
    @Binding var calorie: DietaryEnergy

    var body: some View {
        MeasurementRow(
            measurement: calorie.proteinMeasurement,
            title: "Protein", image: Image.protein, tint: .purple,
            computed: calorie.calculatedProtein(),
            format: .number.precision(.fractionLength(0)),

        )
    }
}

struct MacrosCarbsRow: View {
    @Binding var calorie: DietaryEnergy

    var body: some View {
        MeasurementRow(
            measurement: calorie.carbsMeasurement,
            title: "Carbohydrates", image: Image.carbs, tint: .green,
            computed: calorie.calculatedCarbs(),
            format: .number.precision(.fractionLength(0)),

        )
    }
}

struct MacrosFatRow: View {
    @Binding var calorie: DietaryEnergy

    var body: some View {
        MeasurementRow(
            measurement: calorie.fatMeasurement,
            title: "Fat", image: Image.fat, tint: .yellow,
            computed: calorie.calculatedFat(),
            format: .number.precision(.fractionLength(0)),

        )
    }
}

// MARK: Active Calories
// ============================================================================

struct RestingCaloriesRow: View {
    @Binding var calorie: RestingEnergy

    var body: some View {
        MeasurementRow(
            measurement: calorie.measurement,
            title: "Resting Calories",
            image: Image.restingCalorie, tint: .purple,
            computed: nil,
            format: .number.precision(.fractionLength(0)),

        )
    }
}

struct BurnedCaloriesRow: View {
    @Binding var calorie: ActiveEnergy

    var body: some View {
        MeasurementRow(
            measurement: calorie.measurement,
            title: "Burned Calories",
            image: Image.calories, tint: .orange,
            computed: nil,
            format: .number.precision(.fractionLength(0)),
        )
    }
}

struct ActivityRow: View {
    @Binding var calorie: ActiveEnergy

    var body: some View {
        MeasurementRow(
            measurement: calorie.measurement,
            title: "Activity Calories",
            image: Image.activeCalorie, tint: .green,
            computed: nil,
            format: .number.precision(.fractionLength(0)),
        )
    }
}

// MARK: Weight
// ============================================================================

struct WeightRow: View {
    @Binding var weight: Weight

    var body: some View {
        MeasurementRow(
            measurement: weight.measurement,
            title: "Weight",
            image: Image.weight, tint: .indigo,
            computed: nil,
            format: .number.precision(.fractionLength(2)),
        )
    }
}
