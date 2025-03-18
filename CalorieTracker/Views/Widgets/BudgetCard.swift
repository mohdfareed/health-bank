import SwiftData
import SwiftUI

struct BudgetCard: View {
    @State var title: String
    @State var unit: String?
    @State var color: Color

    @State var budget: UInt = 0
    @State var consumed: Int = 0
    @State var remaining: Int = 0
    @State var progress: Double

    private var progressColor: Color {
        return self.progress > 0.8 ? .red : self.color
    }

    init<T>(
        _ title: String, budget: BudgetService<T>, unit: String? = nil, color: Color = .accentColor
    ) {
        let progress: Double = {
            guard budget.budget > 0 else {
                return 1
            }
            return Double(budget.consumed) / Double(budget.budget)
        }()

        self.budget = budget.budget
        self.consumed = budget.consumed
        self.remaining = budget.remaining
        self.progress = progress

        self.title = title
        self.color = progress > 0.8 ? .red : color
        self.unit = unit
    }

    var body: some View {
        WidgetCard(self.title) {
            // Budget rows
            BudgetItem(title: "Budget", text: "\(self.budget)", unit: "cal")
            BudgetItem(title: "Consumed", text: "\(self.consumed)", unit: "cal")
            BudgetItem(title: "Remaining", text: "\(self.remaining)", unit: "cal")

            // Progress Bar row.
            ProgressView(value: self.progress)
                .accentColor(self.progressColor)
                .progressViewStyle(.linear)
                .frame(height: 8)
                .cornerRadius(4)
                .animation(.easeInOut, value: self.progress)
        }
    }
}

struct BudgetItem: View {
    var title: String
    var text: String
    var unit: String?

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(text)
                .font(.subheadline)
            if let unit = self.unit {
                Text(unit)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
