import SwiftData
import SwiftUI

struct BudgetCard: View {
    @State var title: String
    @State var unit: String?
    @State var color: Color
    @State var endColor: Color

    @State var budget: Double = 0
    @State var consumed: Double = 0
    @State var remaining: Double = 0
    @State var progress: Double = 0

    private var progressColor: Color {
        return self.progress > 0.85 ? self.endColor : self.color
    }

    init(
        _ title: String, budget: BudgetService, unit: String? = nil,
        color: Color = .accentColor, endColor: Color = .red
    ) {
        self.title = title
        self.color = color
        self.endColor = endColor
        self.unit = unit

        self.budget = budget.budget
        self.consumed = budget.consumed
        self.remaining = budget.remaining
        self.progress = budget.progress
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
