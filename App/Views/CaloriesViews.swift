import SwiftData
import SwiftUI

@MainActor struct CalorieEditorVM {
    let calorie = MeasurementFieldVM(
        title: "Calories", image: Image(systemName: AppSymbols.burnedCalorie),
        color: .red, fractions: 0, validator: { $0 < 0 ? 0 : $0 }
    )
    let protein = MeasurementFieldVM(
        title: "Protein", image: Image(systemName: AppSymbols.protein),
        color: .purple, fractions: 0, validator: { $0 < 0 ? 0 : $0 }
    )
    let carbs = MeasurementFieldVM(
        title: "Carbs", image: Image(systemName: AppSymbols.carbs),
        color: .green, fractions: 0, validator: { $0 < 0 ? 0 : $0 }
    )
    let fat = MeasurementFieldVM(
        title: "Fat", image: Image(systemName: AppSymbols.fat),
        color: .yellow, fractions: 0, validator: { $0 < 0 ? 0 : $0 }
    )
}

struct CalorieEditor: View {
    @State var budget: CalorieBudget
    let vm: CalorieEditorVM = .init()

    var body: some View {
        MeasurementField(
            .init(self.$budget.calories, definition: .calorie),
            vm: self.vm.calorie
        )
        MeasurementField(
            .init(self.$budget.macros.proteinValue, definition: .macro),
            vm: self.vm.protein
        )
        MeasurementField(
            .init(self.$budget.macros.carbsValue, definition: .macro),
            vm: self.vm.carbs
        )
        MeasurementField(
            .init(self.$budget.macros.fatValue, definition: .macro),
            vm: self.vm.fat
        )
    }
}

#Preview {
    CalorieEditor(budget: .init())
}
