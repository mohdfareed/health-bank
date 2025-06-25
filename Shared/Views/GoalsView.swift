import SwiftData
import SwiftUI

public struct GoalView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var budget: BudgetService?
    @Query.Singleton var goals: UserGoals
    public init(_ id: UUID) {
        self._goals = .init(id)
    }

    public var body: some View {
        GoalMeasurementField(goals: Bindable(goals))
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
        Section(header: Text("Calorie Goal")) {
            CalorieMaintenanceField(goals.adjustment)
            RecordRow(
                field: CalorieAdjustmentFieldDefinition(),
                value: $goals.adjustment,
                isInternal: true,
                showSign: true
            )
        }

        Section(header: Text("Macros Breakdown")) {
            // Protein field
            RecordRow(
                field: ProteinPercentDefinition().withComputed {
                    100 - (goals.macros?.carbs ?? 0) - (goals.macros?.fat ?? 0)
                },
                value: macrosBinding.protein,
                isInternal: true
            )

            // Carbs field
            RecordRow(
                field: CarbsPercentDefinition().withComputed {
                    100 - (goals.macros?.protein ?? 0) - (goals.macros?.fat ?? 0)
                },
                value: macrosBinding.carbs,
                isInternal: true
            )

            // Fat field
            RecordRow(
                field: FatPercentDefinition().withComputed {
                    100 - (goals.macros?.protein ?? 0) - (goals.macros?.carbs ?? 0)
                },
                value: macrosBinding.fat,
                isInternal: true
            )
        }
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

struct CalorieMaintenanceField: View {
    @Environment(\.widgetDataRepository)
    private var repository

    private let adjustment: Double?

    init(_ adjustment: Double?) {
        self.adjustment = adjustment
    }

    var body: some View {
        RecordRow(
            field: MaintenanceFieldDefinition(),
            value: .constant(repository.budgetData?.weight.maintenance),
            isInternal: false
        )
        .onAppear {
            Task {
                await repository.refreshBudgetData()
            }
        }
    }
}
