import SwiftData
import SwiftUI

struct BudgetView: View {
    @State private var viewModel: BudgetVM

    init(context: ModelContext, budget: CalorieBudget) {
        self.viewModel = BudgetVM(
            budget: budget,
            caloriesService: CaloriesService(context: context)
        )
    }

    /// Computes the budget progress.
    private var progress: Double {
        let progress = Double(viewModel.consumedCalories) / Double(viewModel.caloriesBudget)
        return progress.isNaN ? 0 : progress
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header: Centered title.
            Text(self.viewModel.budgetName)
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // Budget row.
            HStack {
                Text("Budget")
                    .font(.subheadline)
                Spacer()
                Text("\(viewModel.caloriesBudget) kcal")
                    .font(.subheadline)
            }

            // Consumed row.
            HStack {
                Text("Consumed")
                    .font(.subheadline)
                Spacer()
                Text("\(viewModel.consumedCalories) kcal")
                    .font(.subheadline)
            }

            // Remaining row.
            HStack {
                Text("Remaining")
                    .font(.subheadline)
                Spacer()
                Text("\(viewModel.remainingCalories) kcal")
                    .font(.subheadline)
            }

            // Progress Bar row.
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 8)
                .cornerRadius(4)
        }
        .padding()
        .background(Color(Color.secondary))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
