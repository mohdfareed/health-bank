import Foundation

extension AnalyticsService {
    public func estimateMaintenanceCalories(
        weightData: [Date: Double],
        calorieData: [Date: Double],
        weightWindowDays: Int = 14,
        calorieWindowDays: Int = 7
    ) async -> Double? {
        guard !calorieData.isEmpty && !weightData.isEmpty else { return nil }

        // Sort data by date
        let sortedCalories = calorieData.sorted { $0.key < $1.key }
        let sortedWeights = weightData.sorted { $0.key < $1.key }

        // Get recent data for trend analysis
        let recentCalorieData = Array(sortedCalories.suffix(calorieWindowDays))
        let recentWeightData = Array(sortedWeights.suffix(weightWindowDays))

        guard
            recentCalorieData.count >= calorieWindowDays
                && recentWeightData.count >= weightWindowDays
        else {
            // Not enough data, return average calorie intake
            return calorieData.values.reduce(0, +) / Double(calorieData.count)
        }

        // Calculate recent averages
        let recentCalories =
            recentCalorieData.map(\.value)
            .reduce(0, +) / Double(recentCalorieData.count)
        let recentWeight =
            recentWeightData.map(\.value)
            .reduce(0, +) / Double(recentWeightData.count)

        // Get older data for comparison
        let olderCalorieData = Array(
            sortedCalories.dropLast(calorieWindowDays)
                .suffix(calorieWindowDays)
        )
        let olderWeightData = Array(
            sortedWeights.dropLast(weightWindowDays)
                .suffix(weightWindowDays)
        )

        guard !olderCalorieData.isEmpty && !olderWeightData.isEmpty else {
            // Not enough historical data, return recent calorie average
            return recentCalories
        }

        let olderWeight =
            olderWeightData.map(\.value)
            .reduce(0, +) / Double(olderWeightData.count)

        // Calculate weight trend (kg change per day)
        let weightChange = recentWeight - olderWeight
        let weightChangePerDay = weightChange / Double(weightWindowDays)

        // Estimate maintenance based on weight change:
        // If losing weight (negative change), maintenance is higher than current intake
        // If gaining weight (positive change), maintenance is lower than current intake
        // Using approximation: 1 kg body weight ≈ 7700 calories
        let calorieAdjustment = weightChangePerDay * 7700

        // If losing 0.5kg/day, need +0.5kg worth of calories to maintain
        // If gaining 0.5kg/day, need -0.5kg worth of calories to maintain
        return recentCalories - calorieAdjustment
    }
}
