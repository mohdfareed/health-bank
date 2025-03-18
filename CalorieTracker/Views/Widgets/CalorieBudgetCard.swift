import SwiftData
import SwiftUI

struct CalorieBudgetCard: View {
    @Environment(\.modelContext) private var context
    @Query private var consumed: [ConsumedCalories]
    @Query private var burned: [BurnedCalories]

    @State var title: String
    @State var budget: UInt
    @State var color: Color

    var entries: [CalorieEntry] {
        self.consumed + self.burned
    }

    var body: some View {
        let service = CaloriesBudgetService(budget: self.budget, on: self.entries)
        BudgetCard(self.title, budget: service, unit: "cal", color: self.color)
    }

    init(
        _ title: String, budget: UInt, from start: Date, to end: Date, color: Color = .accentColor
    ) {
        self.title = title
        self.budget = budget
        self.color = color

        let consumed: FetchDescriptor<ConsumedCalories> = try! DataEntryService.fetch(
            from: start, to: end)
        let burned: FetchDescriptor<BurnedCalories> = try! DataEntryService.fetch(
            from: start, to: end)

        self._consumed = Query(consumed)
        self._burned = Query(burned)
    }
}
