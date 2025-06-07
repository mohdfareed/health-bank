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
                FieldDefinition.calorie,
                value: $goals.calories, isInternal: true,
                computed: goals.calorieGoal.calculatedCalories
            )
            RecordField(
                FieldDefinition.protein,
                value: macros.protein, isInternal: true,
                computed: goals.calorieGoal.calculatedProtein
            )
            RecordField(
                FieldDefinition.carbs,
                value: macros.carbs, isInternal: true,
                computed: goals.calorieGoal.calculatedCarbs
            )
            RecordField(
                FieldDefinition.fat,
                value: macros.fat, isInternal: true,
                computed: goals.calorieGoal.calculatedFat
            )
            RecordField(
                FieldDefinition.activity,
                value: $goals.activity, isInternal: true,
            )
        }
        .onChange(of: goals) { save() }
        .onChange(of: goals.macros) { save() }
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
