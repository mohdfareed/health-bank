import SwiftData
import SwiftUI

struct GoalSettings: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Query.Singleton var goals: UserGoals
    init(_ id: UUID) {
        self._goals = .init(id)
    }

    var body: some View {
        let macros = $goals.macros.defaulted(to: .init())
        Section(header: Text(String(localized: "Daily Calorie Budget"))) {
            RecordField(
                FieldRegistry.dietaryCalorie,
                value: $goals.calories,
                source: .local,
                computed: goals.calorieGoal.calculatedCalories
            )
            RecordField(
                FieldRegistry.protein,
                value: macros.protein,
                source: .local,
                computed: goals.calorieGoal.calculatedProtein
            )
            RecordField(
                FieldRegistry.carbs,
                value: macros.carbs,
                source: .local,
                computed: goals.calorieGoal.calculatedCarbs
            )
            RecordField(
                FieldRegistry.fat,
                value: macros.fat,
                source: .local,
                computed: goals.calorieGoal.calculatedFat
            )
        }
        .onChange(of: goals) { save() }

        Section(header: Text(String(localized: "Daily Activity Goals"))) {
            RecordField(
                FieldRegistry.calorie,
                value: $goals.burnedCalories,
                source: .local
            )
            RecordField(
                FieldRegistry.activity,
                value: $goals.activity,
                source: .local
            )
        }
        .onChange(of: goals) { save() }

        Section(header: Text(String(localized: "Target Measurements"))) {
            RecordField(
                FieldRegistry.weight,
                value: $goals.weight,
                source: .local,
                showPicker: true
            )
        }
        .onChange(of: goals) { save() }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            AppLogger.new(for: GoalSettings.self)
                .error("Failed to save model: \(error)")
        }
    }
}
