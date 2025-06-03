import SwiftData
import SwiftUI

// TODO: Convert to `Records/Forms.swift` definition.

struct GoalView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Query.Singleton var goals: UserGoals
    init(_ id: UUID) {
        self._goals = .init(id)
    }

    var body: some View {
        let macros = $goals.macros.defaulted(to: .init())
        Section(header: Text("Daily Calorie Budget")) {
            RecordField(
                FieldDefinition.dietaryCalorie,
                value: $goals.calories, source: .local,
                computed: goals.calorieGoal.calculatedCalories
            )
            RecordField(
                FieldDefinition.protein,
                value: macros.protein, source: .local,
                computed: goals.calorieGoal.calculatedProtein
            )
            RecordField(
                FieldDefinition.carbs,
                value: macros.carbs, source: .local,
                computed: goals.calorieGoal.calculatedCarbs
            )
            RecordField(
                FieldDefinition.fat,
                value: macros.fat, source: .local,
                computed: goals.calorieGoal.calculatedFat
            )
        }
        .onChange(of: goals) { save() }
        .onChange(of: goals.macros) { save() }

        Section(header: Text("Daily Activity Goals")) {
            RecordField(
                FieldDefinition.calorie,
                value: $goals.burnedCalories, source: .local
            )
            RecordField(
                FieldDefinition.activity,
                value: $goals.activity, source: .local
            )
        }
        .onChange(of: goals) { save() }

        Section(header: Text("Measurement Goals")) {
            RecordField(
                FieldDefinition.weight,
                value: $goals.weight,
                source: .local, showPicker: true
            )
        }
        .onChange(of: goals) { save() }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            AppLogger.new(for: GoalView.self)
                .error("Failed to save model: \(error)")
        }
    }
}
