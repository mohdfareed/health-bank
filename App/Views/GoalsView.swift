import SwiftData
import SwiftUI

struct GoalView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Query.Singleton var goals: UserGoals
    init(_ id: UUID) {
        self._goals = .init(id)
    }

    var body: some View {
        Section(header: Text("Daily Calorie Budget")) {
            GoalMeasurementField(goals: Bindable(goals))
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

struct GoalMeasurementField: View {
    @Bindable var goals: UserGoals

    init(goals: Bindable<UserGoals>) {
        _goals = goals
    }

    var body: some View {
        // Calories field
        RecordRow(
            field: CalorieFieldDefinition().withComputed {
                goals.calorieGoal.calculatedCalories()
            },
            value: $goals.calories,
            isInternal: true
        )

        // Protein field
        RecordRow(
            field: ProteinFieldDefinition().withComputed {
                goals.calorieGoal.calculatedProtein()
            },
            value: macrosBinding.protein,
            isInternal: true
        )

        // Carbs field
        RecordRow(
            field: CarbsFieldDefinition().withComputed {
                goals.calorieGoal.calculatedCarbs()
            },
            value: macrosBinding.carbs,
            isInternal: true
        )

        // Fat field
        RecordRow(
            field: FatFieldDefinition().withComputed {
                goals.calorieGoal.calculatedFat()
            },
            value: macrosBinding.fat,
            isInternal: true
        )
    }

    private var macrosBinding:
        (
            protein: Binding<Double?>,
            carbs: Binding<Double?>,
            fat: Binding<Double?>
        )
    {
        let macros = $goals.macros.defaulted(to: .init())
        return (
            protein: macros.protein,
            carbs: macros.carbs,
            fat: macros.fat
        )
    }
}
