import SwiftUI

// REVIEW: Simplify and reuse icon+color

// MARK: Calories
// ============================================================================

struct CaloriesRow: View {
    @Binding var calorie: Calorie
    let title: String.LocalizationValue?
    let showDate: Bool

    var body: some View {
        MeasurementRow(
            measurement: calorie.measurement,
            title: title ?? "Calories", image: Image.calories, tint: .orange,
            computed: (calorie as? DietaryCalorie)?.calculatedCalories,
            date: showDate ? calorie.date : nil, source: calorie.source,
            format: .number.precision(.fractionLength(0)), showPicker: false
        )
    }
}

struct DietaryCaloriesRow: View {
    @Binding var calorie: Calorie
    let title: String.LocalizationValue?
    let showDate: Bool

    var body: some View {
        MeasurementRow(
            measurement: calorie.measurement,
            title: title ?? "Calories",
            image: Image.dietaryCalorie, tint: .blue,
            computed: (calorie as? DietaryCalorie)?.calculatedCalories,
            date: showDate ? calorie.date : nil, source: calorie.source,
            format: .number.precision(.fractionLength(0)), showPicker: false
        )
    }
}

struct RestingCaloriesRow: View {
    @Binding var calorie: Calorie
    let showDate: Bool

    var body: some View {
        MeasurementRow(
            measurement: calorie.measurement,
            title: "Resting Energy",
            image: Image.restingCalorie, tint: .indigo,
            computed: nil, date: showDate ? calorie.date : nil,
            source: calorie.source,
            format: .number.precision(.fractionLength(0)), showPicker: false
        )
    }
}

// MARK: Calorie Macros
// ============================================================================

struct MacrosProteinRow: View {
    @Binding var calorie: DietaryCalorie
    let showDate: Bool

    var body: some View {
        MeasurementRow(
            measurement: calorie.proteinMeasurement,
            title: "Protein", image: Image.protein, tint: .purple,
            computed: calorie.calculatedProtein,
            date: showDate ? calorie.date : nil, source: calorie.source,
            format: .number.precision(.fractionLength(0)), showPicker: false
        )
    }
}

struct MacrosCarbsRow: View {
    @Binding var calorie: DietaryCalorie
    let showDate: Bool

    var body: some View {
        MeasurementRow(
            measurement: calorie.carbsMeasurement,
            title: "Carbohydrates", image: Image.carbs, tint: .green,
            computed: calorie.calculatedCarbs,
            date: showDate ? calorie.date : nil, source: calorie.source,
            format: .number.precision(.fractionLength(0)), showPicker: false
        )
    }
}

struct MacrosFatRow: View {
    @Binding var calorie: DietaryCalorie
    let showDate: Bool

    var body: some View {
        MeasurementRow(
            measurement: calorie.fatMeasurement,
            title: "Fat", image: Image.fat, tint: .yellow,
            computed: calorie.calculatedFat,
            date: showDate ? calorie.date : nil, source: calorie.source,
            format: .number.precision(.fractionLength(0)), showPicker: false
        )
    }
}

// MARK: Active Calories
// ============================================================================

struct ActivityRow: View {
    @Binding var calorie: ActiveEnergy
    let showDate: Bool
    let showPicker: Bool

    var body: some View {
        MeasurementRow(
            measurement: calorie.durationMeasurement,
            title: "Activity",
            image: Image.activeCalorie, tint: .green,
            computed: nil, date: showDate ? calorie.date : nil,
            source: calorie.source,
            format: .number.precision(.fractionLength(0)),
            showPicker: showPicker
        )
    }
}

// MARK: Weight
// ============================================================================

struct WeightRow: View {
    @Binding var weight: Weight
    let showDate: Bool

    var body: some View {
        MeasurementRow(
            measurement: weight.measurement,
            title: "Weight",
            image: Image.weight, tint: .indigo,
            computed: nil, date: showDate ? weight.date : nil,
            source: weight.source,
            format: .number.precision(.fractionLength(2)), showPicker: true
        )
    }
}
