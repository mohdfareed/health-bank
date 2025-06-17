import Foundation
import SwiftData
import SwiftUI

@MainActor @propertyWrapper
struct CalorieAnalytics: DynamicProperty {
    @Environment(\.healthKit)
    var healthKitService: HealthKitService
    let analyticsService: AnalyticsService = .init()
    @State var calorieAnalytics: DataAnalyticsService? = nil

    var wrappedValue: DataAnalyticsService? {
        calorieAnalytics
    }
    var projectedValue: Self { self }

    func reload(at date: Date) async {
        let ewmaRange = DataAnalyticsService.ewmaDateRange(from: date)
        let currentRange = DataAnalyticsService.currentDateRange(from: date)

        // Get calorie data for the past 7 days
        let calorieData = await healthKitService.fetchStatistics(
            for: .dietaryCalories,
            from: ewmaRange.from, to: ewmaRange.to,
            interval: .daily,
            options: .cumulativeSum
        )

        // Get calorie data for the past 7 days
        let currentData = await healthKitService.fetchStatistics(
            for: .dietaryCalories,
            from: currentRange.from, to: currentRange.to,
            interval: .daily,
            options: .cumulativeSum
        )

        // Create services
        let newAnalytics = DataAnalyticsService(
            analytics: analyticsService,
            currentIntakes: currentData,
            intakes: calorieData, alpha: 0.25,
        )

        await MainActor.run {
            withAnimation(.default) {
                calorieAnalytics = newAnalytics
            }
        }
    }
}
