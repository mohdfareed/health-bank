import Foundation
import SwiftData
import SwiftUI

@MainActor @propertyWrapper
public struct CalorieAnalytics: DynamicProperty {
    @Environment(\.healthKit)
    var healthKitService: HealthKitService
    @State var calorieAnalytics: DataAnalyticsService? = nil

    public init() {}

    public var wrappedValue: DataAnalyticsService? {
        calorieAnalytics
    }
    public var projectedValue: Self { self }

    public func reload(at date: Date) async {
        // REVIEW: Add a setting to control the range
        let yesterday = date.adding(-1, .day, using: .autoupdatingCurrent)
        let ewmaRange = yesterday?.dateRange(by: 7, using: .autoupdatingCurrent)
        let currentRange = date.dateRange(using: .autoupdatingCurrent)
        guard let ewmaRange, let currentRange else {
            AppLogger.new(for: self).error(
                "Failed to calculate date ranges for EWMA at: \(date)"
            )
            return
        }

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
