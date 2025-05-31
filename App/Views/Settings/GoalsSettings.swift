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
            MeasurementRow.dietaryCalorie(
                measurement: .calorie($goals.calories),
                title: "Calories", source: .local,
                computed: goals.calorieGoal.calculatedCalories
            )
            MeasurementRow.protein(
                measurement: .macro(macros.protein),
                source: .local,
                computed: goals.calorieGoal.calculatedProtein
            )
            MeasurementRow.carbs(
                measurement: .macro(macros.carbs),
                source: .local,
                computed: goals.calorieGoal.calculatedCarbs
            )
            MeasurementRow.fat(
                measurement: .macro(macros.fat),
                source: .local,
                computed: goals.calorieGoal.calculatedFat
            )
        }
        .onChange(of: goals) { save() }

        Section(header: Text(String(localized: "Daily Activity Goals"))) {
            MeasurementRow.calorie(
                measurement: .calorie($goals.burnedCalories),
                source: .local,
            )
            MeasurementRow.activity(
                measurement: .activity($goals.activity),
                source: .local
            )
        }
        .onChange(of: goals) { save() }

        Section(header: Text(String(localized: "Target Measurements"))) {
            MeasurementRow.weight(
                measurement: .weight($goals.weight),
                source: .local, showPicker: true
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
