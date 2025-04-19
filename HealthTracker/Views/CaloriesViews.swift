import SwiftData
import SwiftUI

struct CalorieEditor: View {
    @State var budget: CalorieBudget

    var body: some View {
        Text("\(Image(systemName: "swift")) Hello World!")
        Form {
            MeasurementField(
                .init(self.$budget.calories, definition: .calorie),
                title: "Calories", image: Image(systemName: AppIcons.burnedCalorie),
                color: .red, computed: self.budget.calculatedCalories(),
                fractions: 0, validator: { $0 < 0 ? 0 : $0 }
            )
            MeasurementField(
                .init(
                    self.$budget.macros.defaulted(to: .init()).protein.defaulted(to: 0),
                    definition: .macro
                ),
                title: "Protein", image: Image(systemName: AppIcons.protein),
                color: .purple, computed: self.budget.calculatedProtein(),
                fractions: 0, validator: { $0 < 0 ? 0 : $0 }
            )
            MeasurementField(
                .init(
                    self.$budget.macros.defaulted(to: .init()).carbs.defaulted(to: 0),
                    definition: .macro
                ),
                title: "Carbs", image: Image(systemName: AppIcons.carbs),
                color: .green, computed: self.budget.calculatedCarbs(),
                fractions: 0, validator: { $0 < 0 ? 0 : $0 }
            )
            MeasurementField(
                .init(
                    self.$budget.macros.defaulted(to: .init()).fat.defaulted(to: 0),
                    definition: .macro
                ),
                title: "Fat", image: Image(systemName: AppIcons.fat),
                color: .yellow, computed: self.budget.calculatedFat(),
                fractions: 0, validator: { $0 < 0 ? 0 : $0 }
            )  // TODO: re-organize to re-use definitions
        }
    }
}

#Preview {
    CalorieEditor(budget: .init())
}
