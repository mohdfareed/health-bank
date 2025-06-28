import Foundation
import SwiftUI

extension BudgetService {
    @ViewBuilder
    func progress(color: Color = .accent, icon: Image?) -> ProgressRing {
        ProgressRing(
            value: self.baseBudget ?? 1,
            progress: calories.currentIntake ?? 0,
            color: color,
            tip: (self.budget ?? 1),
            tipColor: (self.credit ?? 0) >= 0 ? .green : .red,
            icon: icon
        )
    }
}

@MainActor @propertyWrapper
public struct BudgetAnalytics: DynamicProperty {
    @AppLocale var locale: Locale
    @WeightAnalytics var weightAnalytics: WeightAnalyticsService?
    @State var budgetAnalytics: BudgetService? = nil

    let adjustment: Double?
    public init(adjustment: Double? = nil) {
        self.adjustment = adjustment
    }

    public var wrappedValue: BudgetService? {
        budgetAnalytics
    }
    public var projectedValue: Self { self }

    public func reload(at date: Date) async {
        await $weightAnalytics.reload(at: date)
        guard let weightAnalytics = weightAnalytics else { return }

        await MainActor.run {
            withAnimation(.default) {
                budgetAnalytics = .init(
                    calories: weightAnalytics.calories,
                    weight: weightAnalytics,
                    adjustment: adjustment,
                    firstWeekday: locale.calendar.firstWeekday
                )
            }
        }
    }
}
