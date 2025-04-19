import SwiftData
import SwiftUI

struct CalorieEditor: View {
    var body: some View {
        // MeasurementField(
        //     text: String(localized: "Calories"),
        //     image: AppIcons.dietaryCalorie, color: .orange, fractions: 0,
        //     validator: {
        //         guard $0 ?? 0 < 0 else {
        //             return Text(String(localized: "Daily calories"))
        //         }
        //         return self.budgetError
        //     },
        //     measurement: .init(
        //         self.$budget.calories.optional(0), definition: .calorie
        //     ),
        //     computed: self.budget.calculatedCalories()
        // )
        Text("\(Image(systemName: "swift")) Hello World!")
    }
}

#Preview {
    CalorieEditor()
}
