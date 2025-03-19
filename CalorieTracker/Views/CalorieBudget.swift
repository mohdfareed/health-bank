import SwiftData
import SwiftUI

struct CalorieBudgetCard: View {
    @Environment(\.modelContext) private var context
    @Query private var consumed: [ConsumedCalories]
    @Query private var burned: [BurnedCalories]

    @State var title: String
    @State var budget: Double
    @State var color: Color

    var entries: [DataEntry] {
        self.consumed + self.burned
    }

    var body: some View {
        let service = try! BudgetService(self.budget, on: self.entries.values)
        BudgetCard(self.title, budget: service, unit: "cal", color: self.color)
    }

    init(
        _ title: String, budget: Double, from start: Date, to end: Date,
        color: Color = .accentColor
    ) {
        guard start < end else {
            DataError.InvalidDateRange(from: start, to: end)
        }
        guard budget > 0 else {
            DataError.InvalidData("Budget must be greater than 0.")
        }

        self.title = title
        self.budget = budget
        self.color = color

        let consumed: FetchDescriptor<ConsumedCalories> = try! DataService.fetch(
            over: DateInterval(start: start, end: end)
        )
        let burned: FetchDescriptor<BurnedCalories> = try! DataService.fetch(
            over: DateInterval(start: start, end: end)
        )

        self._consumed = Query(consumed)
        self._burned = Query(burned)
    }
}
