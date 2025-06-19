import Foundation
import SwiftData
import SwiftUI

@MainActor @propertyWrapper
struct WeightAnalytics: DynamicProperty {
    @Environment(\.healthKit)
    var healthKitService: HealthKitService
    let analyticsService: AnalyticsService = .init()
    @CalorieAnalytics var calorieAnalytics: DataAnalyticsService?

    @State var analytics: WeightAnalyticsService? = nil

    var wrappedValue: WeightAnalyticsService? {
        analytics
    }
    var projectedValue: Self { self }

    func reload(at date: Date) async {
        await $calorieAnalytics.reload(at: date)
        guard let calorieAnalytics = calorieAnalytics else { return }
        let fittingRange = DataAnalyticsService.fittingDateRange(from: date)

        // Get calorie data for the past 14 days
        let weightData = await healthKitService.fetchStatistics(
            for: .bodyMass,
            from: fittingRange.from, to: fittingRange.to,
            interval: .daily,
            options: .discreteAverage
        )

        // Create services
        let newAnalytics = WeightAnalyticsService(
            analytics: analyticsService,
            calories: calorieAnalytics,
            weights: weightData, rho: 7700
        )

        await MainActor.run {
            withAnimation(.default) {
                analytics = newAnalytics
            }
        }
    }
}
