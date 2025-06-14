import Charts
import SwiftData
import SwiftUI

// MARK: - Budget Overview Widget
// ============================================================================

struct BudgetOverviewWidget: View {
    let healthKitService: HealthKitService
    let analyticsService: AnalyticsService
    let budgetService: BudgetService

    @State private var budgetData: BudgetData?
    @State private var isLoading = true

    struct BudgetData {
        let baseBudget: Double
        let adjustedBudget: Double
        let consumed: Double
        let remaining: Double
        let adjustment: Double
        let averageIntake: Double
    }

    var body: some View {
        DashboardCard(
            title: "Budget Overview",
            icon: Image(systemName: "chart.bar.fill"),
            color: .orange
        ) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if let data = budgetData {
                BudgetContent(data: data)
            } else {
                Text("Unable to load budget data")
                    .foregroundColor(.secondary)
            }
        } destination: {
            BudgetDetailView(
                healthKitService: healthKitService,
                analyticsService: analyticsService,
                budgetService: budgetService
            )
        }
        .task {
            await loadBudgetData()
        }
    }

    @ViewBuilder
    private func BudgetContent(data: BudgetData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Remaining calories display
            HStack {
                Text("\(Int(data.remaining))")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(data.remaining >= 0 ? .primary : .red)

                Text("kcal remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }

            // Budget breakdown
            VStack(alignment: .leading, spacing: 4) {
                Text("Base Budget: \(Int(data.baseBudget)) kcal")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if abs(data.adjustment) > 1 {
                    Text(
                        "7-day Adjustment: \(data.adjustment > 0 ? "+" : "")\(Int(data.adjustment)) kcal"
                    )
                    .font(.caption)
                    .foregroundColor(data.adjustment > 0 ? .green : .red)
                }

                Text("Adjusted Budget: \(Int(data.adjustedBudget)) kcal")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            // Progress bar
            ProgressView(value: data.consumed, total: data.adjustedBudget)
                .tint(data.consumed <= data.adjustedBudget ? .green : .red)
        }
    }

    private func loadBudgetData() async {
        isLoading = true
        defer { isLoading = false }

        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate)!

        // Get calorie data for the past 7 days
        let calorieData = await healthKitService.fetchStatistics(
            for: .dietaryCalories,
            from: startDate,
            to: endDate,
            interval: .daily,
            options: .cumulativeSum
        )

        // Get today's consumed calories
        let todayStart = Calendar.current.startOfDay(for: endDate)
        let todayCalories = await healthKitService.fetchStatistics(
            for: .dietaryCalories,
            from: todayStart,
            to: endDate,
            interval: .daily,
            options: .cumulativeSum
        )

        // Calculate running average
        let runningAverages = try? analyticsService.calculateRunningAverage(
            data: calorieData,
            windowSize: 7,
            unit: .day
        )

        let averageIntake = runningAverages?.values.sorted().last ?? 0
        let baseBudget = 2000.0  // This should come from settings
        let adjustedBudget = budgetService.calculateAdjustedBudget(
            baseBudget: baseBudget,
            averageIntake: averageIntake
        )

        let consumed = todayCalories.values.first ?? 0
        let remaining = adjustedBudget - consumed
        let adjustment = adjustedBudget - baseBudget

        budgetData = BudgetData(
            baseBudget: baseBudget,
            adjustedBudget: adjustedBudget,
            consumed: consumed,
            remaining: remaining,
            adjustment: adjustment,
            averageIntake: averageIntake
        )
    }
}

// MARK: - Budget Detail View
// ============================================================================

struct BudgetDetailView: View {
    let healthKitService: HealthKitService
    let analyticsService: AnalyticsService
    let budgetService: BudgetService

    @State private var chartData: [WeeklyBudgetData] = []
    @State private var isLoading = true

    struct WeeklyBudgetData: Identifiable {
        let id = UUID()
        let weekStart: Date
        let weekEnd: Date
        let averageCalories: Double
        let budgetTarget: Double
        let adjustment: Double
        let weekLabel: String
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if isLoading {
                ProgressView("Loading budget data...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
            }
        }
        .navigationTitle("Budget Overview")
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
                // Average calories bars
                BarMark(
                    x: .value("Week", data.weekLabel),
                    y: .value("Calories", data.averageCalories)
                )
                .foregroundStyle(.orange.gradient)
                .opacity(0.8)

                // Budget target line
                RuleMark(
                    x: .value("Week", data.weekLabel),
                    yStart: .value("Target", data.budgetTarget),
                    yEnd: .value("Target", data.budgetTarget)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
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
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(orientation: .vertical) {
                    Text(value.as(String.self) ?? "")
                        .font(.caption)
                        .rotationEffect(.degrees(-45))
                }
            }
        }

        // Legend
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Rectangle()
                    .fill(.orange.gradient)
                    .frame(width: 16, height: 12)
                Text("Average Weekly Calories")
                    .font(.caption)
                Spacer()
            }

            HStack {
                Rectangle()
                    .fill(.blue)
                    .frame(width: 16, height: 2)
                Text("Budget Target")
                    .font(.caption)
                Spacer()
            }
        }
        .padding(.horizontal)

        // Summary
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Summary")
                .font(.headline)

            if let totalAvg = chartData.map(\.averageCalories).average() {
                Text("Average Daily Calories: \(Int(totalAvg))")
                    .font(.subheadline)
            }

            if let bestWeek = chartData.min(by: {
                abs($0.averageCalories - $0.budgetTarget)
                    < abs($1.averageCalories - $1.budgetTarget)
            }) {
                Text("Best Week: \(bestWeek.weekLabel)")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func loadChartData() async {
        isLoading = true
        defer { isLoading = false }

        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!

        // Get weekly data for the past month
        let weeklyData = await healthKitService.fetchStatistics(
            for: .dietaryCalories,
            from: startDate,
            to: endDate,
            interval: .weekly,
            options: .cumulativeSum
        )

        let calendar = Calendar.current
        var weeklyBudgetData: [WeeklyBudgetData] = []

        let sortedWeeks = weeklyData.sorted { $0.key < $1.key }

        for (index, (weekStart, totalCalories)) in sortedWeeks.enumerated() {
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
            let daysInWeek =
                calendar.dateComponents([.day], from: weekStart, to: min(weekEnd, endDate)).day ?? 7
            let averageCalories = totalCalories / Double(max(daysInWeek, 1))

            let weekLabel = "Week \(index + 1)"
            let budgetTarget = 2000.0  // This should come from settings

            // Calculate running average adjustment
            let runningAverages = try? analyticsService.calculateRunningAverage(
                data: weeklyData,
                windowSize: min(3, sortedWeeks.count),
                unit: .weekOfYear
            )

            let currentAvg = runningAverages?[weekStart] ?? averageCalories
            let adjustment =
                budgetService.calculateAdjustedBudget(
                    baseBudget: budgetTarget,
                    averageIntake: currentAvg
                ) - budgetTarget

            weeklyBudgetData.append(
                WeeklyBudgetData(
                    weekStart: weekStart,
                    weekEnd: weekEnd,
                    averageCalories: averageCalories,
                    budgetTarget: budgetTarget,
                    adjustment: adjustment,
                    weekLabel: weekLabel
                ))
        }

        chartData = weeklyBudgetData
    }
}
