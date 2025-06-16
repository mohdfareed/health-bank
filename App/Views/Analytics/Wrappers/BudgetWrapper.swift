import Foundation
import SwiftUI

extension BudgetService {
    @ViewBuilder
    func progress(color: Color = .accent, icon: Image?) -> ProgressRing {
        let remaining =
            (self.budget ?? .infinity)
            - (calories.currentIntake ?? 0)

        ProgressRing(
            value: self.baseBudget ?? 1,
            progress: calories.currentIntake ?? 0,
            color: remaining >= 0 ? color : .red,
            tip: (self.budget ?? 1),
            tipColor: (self.credit ?? 0) >= 0 ? .green : .red,
            icon: icon
        )
    }
}

@MainActor @propertyWrapper
struct BudgetAnalytics: DynamicProperty {
    @AppLocale var locale: Locale
    @WeightAnalytics var weightAnalytics: WeightAnalyticsService?
    @State var budgetAnalytics: BudgetService? = nil

    let adjustment: Double?
    var wrappedValue: BudgetService? {
        budgetAnalytics
    }
    var projectedValue: Self { self }

    func reload(at date: Date) async {
        await $weightAnalytics.reload(at: date)
        guard let weightAnalytics = weightAnalytics else { return }

        let nextWeek = date.next(locale.calendar.firstWeekday)
        let daysLeft = date.distance(to: nextWeek, in: .day)!

        await MainActor.run {
            withAnimation(.default) {
                budgetAnalytics = .init(
                    calories: weightAnalytics.calories,
                    weight: weightAnalytics,
                    adjustment: adjustment,
                    daysLeft: daysLeft
                )
            }
        }
    }
}
