import SwiftData
import SwiftUI

struct DailyBudgetView: View {
    @State private var viewModel: BudgetVM

    init(_ viewModel: BudgetVM) {
        self.viewModel = viewModel
    }

    /// Computes the budget progress.
    private var progress: Double {
        let progress = Double(viewModel.dailyConsumed) / Double(viewModel.dailyBudget)
        return progress.isNaN ? 0 : progress
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header.
            Text("Daily Budget")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // Budget row.
            HStack {
                Text("Budget")
                    .font(.subheadline)
                Spacer()
                Text("\(viewModel.dailyBudget) kcal")
                    .font(.subheadline)
            }

            // Consumed row.
            HStack {
                Text("Consumed")
                    .font(.subheadline)
                Spacer()
                Text("\(viewModel.dailyConsumed) kcal")
                    .font(.subheadline)
            }

            // Remaining row.
            HStack {
                Text("Remaining")
                    .font(.subheadline)
                Spacer()
                Text("\(viewModel.dailyRemaining) kcal")
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
