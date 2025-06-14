import Charts
import SwiftData
import SwiftUI

// MARK: - Maintenance Discovery Widget
// ============================================================================

struct MaintenanceDiscoveryWidget: View {
    let healthKitService: HealthKitService
    let analyticsService: AnalyticsService

    @State private var maintenanceData: MaintenanceData?
    @State private var isLoading = true

    struct MaintenanceData {
        let estimatedMaintenance: Double
        let currentBudget: Double
        let deficitSurplus: Double
        let confidence: String
    }

    var body: some View {
        DashboardCard(
            title: "Maintenance Discovery",
            icon: Image(systemName: "target"),
            color: .blue
        ) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if let data = maintenanceData {
                MaintenanceContent(data: data)
            } else {
                Text("Insufficient data for maintenance estimation")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        } destination: {
            MaintenanceDetailView(
                healthKitService: healthKitService,
                analyticsService: analyticsService
            )
        }
        .task {
            await loadMaintenanceData()
        }
    }

    @ViewBuilder
    private func MaintenanceContent(data: MaintenanceData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Estimated maintenance
            HStack {
                Text("\(Int(data.estimatedMaintenance))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("kcal/day")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }

            // Deficit/Surplus
            HStack {
                Image(systemName: data.deficitSurplus < 0 ? "arrow.down" : "arrow.up")
                    .foregroundColor(data.deficitSurplus < 0 ? .green : .red)

                Text(
                    "\(abs(Int(data.deficitSurplus))) kcal \(data.deficitSurplus < 0 ? "deficit" : "surplus")"
                )
                .font(.headline)
                .foregroundColor(data.deficitSurplus < 0 ? .green : .red)

                Spacer()
            }

            Text("Confidence: \(data.confidence)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func loadMaintenanceData() async {
        isLoading = true
        defer { isLoading = false }

        let analytics = AnalyticsService()

        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate)!

        // Get weight and calorie data
        let weightData = await healthKitService.fetchStatistics(
            for: .bodyMass,
            from: startDate,
            to: endDate,
            interval: .daily,
            options: .discreteAverage
        )

        let calorieData = await healthKitService.fetchStatistics(
            for: .dietaryCalories,
            from: startDate,
            to: endDate,
            interval: .daily,
            options: .cumulativeSum
        )

        guard
            let estimatedMaintenance = await analytics.estimateMaintenanceCalories(
                weightData: weightData,
                calorieData: calorieData,
                weightWindowDays: 14,
                calorieWindowDays: 7
            )
        else {
            return
        }

        let currentBudget = 2000.0  // This should come from settings
        let deficitSurplus = currentBudget - estimatedMaintenance

        // Calculate confidence based on data availability
        let confidence: String
        if calorieData.count >= 7 && weightData.count >= 14 {
            confidence = "High"
        } else if calorieData.count >= 5 && weightData.count >= 10 {
            confidence = "Medium"
        } else {
            confidence = "Low"
        }

        maintenanceData = MaintenanceData(
            estimatedMaintenance: estimatedMaintenance,
            currentBudget: currentBudget,
            deficitSurplus: deficitSurplus,
            confidence: confidence
        )
    }
}

// MARK: - Maintenance Detail View
// ============================================================================

struct MaintenanceDetailView: View {
    let healthKitService: HealthKitService
    let analyticsService: AnalyticsService

    @State private var chartData: [WeeklyMaintenanceData] = []
    @State private var isLoading = true

    struct WeeklyMaintenanceData: Identifiable {
        let id = UUID()
        let week: Date
        let estimatedMaintenance: Double
        let averageCalories: Double
        let weightChange: Double
        let weekLabel: String
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if isLoading {
                ProgressView("Loading maintenance data...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                chartContent
            }
        }
        .navigationTitle("Maintenance Discovery")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
        #endif
        .task {
            await loadChartData()
        }
    }

    @ViewBuilder
    private var chartContent: some View {
        // Chart
        Chart {
            ForEach(chartData) { data in
                // Estimated maintenance line
                LineMark(
                    x: .value("Week", data.weekLabel),
                    y: .value("Maintenance", data.estimatedMaintenance)
                )
                .foregroundStyle(.blue)
                .symbol(.circle)

                // Average calories line
                LineMark(
                    x: .value("Week", data.weekLabel),
                    y: .value("Calories", data.averageCalories)
                )
                .foregroundStyle(.orange)
                .symbol(.square)
            }
        }
        .frame(height: 300)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    Text("\(Int(value.as(Double.self) ?? 0))")
                        .font(.caption)
                }
            }
        }

        // Legend
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(.blue)
                    .frame(width: 12, height: 12)
                Text("Estimated Maintenance")
                    .font(.caption)
                Spacer()
            }

            HStack {
                Rectangle()
                    .fill(.orange)
                    .frame(width: 12, height: 12)
                Text("Average Calories")
                    .font(.caption)
                Spacer()
            }
        }
        .padding(.horizontal)

        // Summary
        VStack(alignment: .leading, spacing: 12) {
            Text("Analysis")
                .font(.headline)

            if let avgMaintenance = chartData.map(\.estimatedMaintenance).average() {
                Text("Average Maintenance: \(Int(avgMaintenance)) kcal/day")
                    .font(.subheadline)
            }

            let totalWeightChange = chartData.map(\.weightChange).reduce(0, +)
            Text(
                "Total Weight Change: \(totalWeightChange > 0 ? "+" : "")\(totalWeightChange, specifier: "%.1f") kg"
            )
            .font(.subheadline)
            .foregroundColor(totalWeightChange > 0 ? .red : .green)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func loadChartData() async {
        isLoading = true
        defer { isLoading = false }

        let analytics = AnalyticsService()
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!

        // Get weekly weight and calorie data
        let weeklyCalories = await healthKitService.fetchStatistics(
            for: .dietaryCalories,
            from: startDate,
            to: endDate,
            interval: .weekly,
            options: .cumulativeSum
        )

        let weeklyWeight = await healthKitService.fetchStatistics(
            for: .bodyMass,
            from: startDate,
            to: endDate,
            interval: .weekly,
            options: .discreteAverage
        )

        let sortedWeeks = weeklyCalories.sorted { $0.key < $1.key }
        var maintenanceData: [WeeklyMaintenanceData] = []

        for (index, (weekStart, totalCalories)) in sortedWeeks.enumerated() {
            let weekLabel = "Week \(index + 1)"
            let averageCalories = totalCalories / 7.0  // Convert weekly total to daily average

            // Estimate maintenance for this week
            let maintenance =
                await analytics.estimateMaintenanceCalories(
                    weightData: weeklyWeight,
                    calorieData: weeklyCalories,
                    weightWindowDays: 14,
                    calorieWindowDays: 7
                ) ?? averageCalories

            // Calculate weight change
            let weightChange = weeklyWeight[weekStart] ?? 0

            maintenanceData.append(
                WeeklyMaintenanceData(
                    week: weekStart,
                    estimatedMaintenance: maintenance,
                    averageCalories: averageCalories,
                    weightChange: weightChange,
                    weekLabel: weekLabel
                ))
        }

        chartData = maintenanceData
    }
}
