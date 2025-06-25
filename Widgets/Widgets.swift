import HealthVaultsShared
import SwiftUI
import WidgetKit

struct BudgetTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> BudgetEntry {
        BudgetEntry(date: Date(), budgetService: nil, configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async
        -> BudgetEntry
    {
        await generateEntry(for: Date(), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<
        BudgetEntry
    > {
        let currentDate = Date()
        let entry = await generateEntry(for: currentDate, configuration: configuration)

        // Schedule next update in 1 hour to refresh the data
        let nextUpdate =
            Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate

        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    @MainActor
    private func generateEntry(for date: Date, configuration: ConfigurationAppIntent) async
        -> BudgetEntry
    {
        // Create the analytics wrapper
        let budgetAnalytics = BudgetAnalytics()

        // Load the data
        await budgetAnalytics.reload(at: date)

        return BudgetEntry(
            date: date,
            budgetService: budgetAnalytics.wrappedValue,
            configuration: configuration
        )
    }
}

struct BudgetEntry: TimelineEntry, Sendable {
    let date: Date
    let budgetService: BudgetService?
    let configuration: ConfigurationAppIntent
}

struct BudgetWidgetEntryView: View {
    var entry: BudgetTimelineProvider.Entry

    var body: some View {
        if let budgetService = entry.budgetService {
            // Create a simplified budget widget view for the widget extension
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "chart.pie.fill")
                        .foregroundColor(.orange)
                    Text("Calories")
                        .font(.headline)
                        .fontWeight(.medium)
                    Spacer()
                }

                // Remaining calories
                HStack(alignment: .firstTextBaseline) {
                    if let remaining = budgetService.remaining {
                        Text("\(Int(remaining))")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(remaining >= 0 ? .primary : .red)
                        Text("remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("---")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }

                // Progress info
                HStack {
                    if let currentIntake = budgetService.calories.currentIntake,
                        let budget = budgetService.budget
                    {
                        Text("\(Int(currentIntake)) / \(Int(budget))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }
            .padding()
        } else {
            VStack {
                Image(systemName: "chart.pie.fill")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct BudgetWidgetKit: Widget {
    let kind: String = BudgetWidgetID

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind, intent: ConfigurationAppIntent.self, provider: BudgetTimelineProvider()
        ) { entry in
            BudgetWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Calorie Budget")
        .description("Track your daily calorie budget and remaining calories.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
}

#Preview(as: .systemSmall) {
    BudgetWidgetKit()
} timeline: {
    BudgetEntry(date: .now, budgetService: nil, configuration: .smiley)
}

// MARK: - Macros Widget
// ============================================================================

struct MacrosTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MacrosEntry {
        MacrosEntry(date: Date(), macrosService: nil, configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async
        -> MacrosEntry
    {
        await generateEntry(for: Date(), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<
        MacrosEntry
    > {
        let currentDate = Date()
        let entry = await generateEntry(for: currentDate, configuration: configuration)

        // Schedule next update in 1 hour to refresh the data
        let nextUpdate =
            Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate

        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    @MainActor
    private func generateEntry(for date: Date, configuration: ConfigurationAppIntent) async
        -> MacrosEntry
    {
        // Create the analytics wrapper with default budget adjustment
        let budgetAnalytics = BudgetAnalytics()
        let macrosAnalytics = MacrosAnalytics(budgetAnalytics: budgetAnalytics)

        // Load the data
        await macrosAnalytics.reload(at: date)

        return MacrosEntry(
            date: date,
            macrosService: macrosAnalytics.wrappedValue,
            configuration: configuration
        )
    }
}

struct MacrosEntry: TimelineEntry, Sendable {
    let date: Date
    let macrosService: MacrosAnalyticsService?
    let configuration: ConfigurationAppIntent
}

struct MacrosWidgetEntryView: View {
    var entry: MacrosTimelineProvider.Entry

    var body: some View {
        if let macrosService = entry.macrosService {
            // Create a simplified macros widget view for the widget extension
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.green)
                    Text("Macros")
                        .font(.headline)
                        .fontWeight(.medium)
                    Spacer()
                }

                // Macro breakdown
                HStack(spacing: 12) {
                    MacroColumn(
                        name: "Protein",
                        current: macrosService.protein.currentIntake ?? 0,
                        budget: macrosService.budgets?.protein ?? 0,
                        color: .blue
                    )
                    MacroColumn(
                        name: "Carbs",
                        current: macrosService.carbs.currentIntake ?? 0,
                        budget: macrosService.budgets?.carbs ?? 0,
                        color: .orange
                    )
                    MacroColumn(
                        name: "Fat",
                        current: macrosService.fat.currentIntake ?? 0,
                        budget: macrosService.budgets?.fat ?? 0,
                        color: .red
                    )
                }
            }
            .padding()
        } else {
            VStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct MacroColumn: View {
    let name: String
    let current: Double
    let budget: Double
    let color: Color

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(color)

            Text("\(Int(current))")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("/\(Int(budget))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MacrosWidgetKit: Widget {
    let kind: String = MacrosWidgetID

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind, intent: ConfigurationAppIntent.self, provider: MacrosTimelineProvider()
        ) { entry in
            MacrosWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Macro Nutrients")
        .description("Track your daily protein, carbs, and fat intake.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    MacrosWidgetKit()
} timeline: {
    MacrosEntry(date: .now, macrosService: nil, configuration: .smiley)
}

// MARK: - Overview Widget
// ============================================================================

struct OverviewTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> OverviewEntry {
        OverviewEntry(date: Date(), macrosService: nil, configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async
        -> OverviewEntry
    {
        await generateEntry(for: Date(), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<
        OverviewEntry
    > {
        let currentDate = Date()
        let entry = await generateEntry(for: currentDate, configuration: configuration)

        // Schedule next update in 1 hour to refresh the data
        let nextUpdate =
            Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate

        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }

    @MainActor
    private func generateEntry(for date: Date, configuration: ConfigurationAppIntent) async
        -> OverviewEntry
    {
        // Create the analytics wrapper with default budget adjustment
        let budgetAnalytics = BudgetAnalytics()
        let macrosAnalytics = MacrosAnalytics(budgetAnalytics: budgetAnalytics)

        // Load the data
        await macrosAnalytics.reload(at: date)

        return OverviewEntry(
            date: date,
            macrosService: macrosAnalytics.wrappedValue,
            configuration: configuration
        )
    }
}

struct OverviewEntry: TimelineEntry, Sendable {
    let date: Date
    let macrosService: MacrosAnalyticsService?
    let configuration: ConfigurationAppIntent
}

struct OverviewWidgetEntryView: View {
    var entry: OverviewTimelineProvider.Entry

    var body: some View {
        if let macrosService = entry.macrosService {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.line.text.clipboard.fill")
                        .foregroundColor(.blue)
                    Text("Overview")
                        .font(.headline)
                        .fontWeight(.medium)
                    Spacer()
                }

                // Calories section
                if let budget = macrosService.budget {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Calories")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            if let remaining = budget.remaining {
                                Text("\(Int(remaining))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(remaining >= 0 ? .primary : .red)
                            } else {
                                Text("---")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        // Weight trend
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Weight Trend")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            let slope = budget.weight.weightSlope
                            Text("\(slope >= 0 ? "+" : "")\(slope, specifier: "%.1f") kg/wk")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(slope > 0 ? .red : slope < 0 ? .green : .blue)
                        }
                    }
                }

                // Quick macro summary
                HStack(spacing: 16) {
                    MacroSummary(
                        name: "P",
                        current: macrosService.protein.currentIntake ?? 0,
                        budget: macrosService.budgets?.protein ?? 0,
                        color: .blue
                    )
                    MacroSummary(
                        name: "C",
                        current: macrosService.carbs.currentIntake ?? 0,
                        budget: macrosService.budgets?.carbs ?? 0,
                        color: .orange
                    )
                    MacroSummary(
                        name: "F",
                        current: macrosService.fat.currentIntake ?? 0,
                        budget: macrosService.budgets?.fat ?? 0,
                        color: .red
                    )
                }
            }
            .padding()
        } else {
            VStack {
                Image(systemName: "chart.line.text.clipboard.fill")
                    .font(.title)
                    .foregroundColor(.secondary)
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct MacroSummary: View {
    let name: String
    let current: Double
    let budget: Double
    let color: Color

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(name)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(color)

            Text("\(Int(current))")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("/\(Int(budget))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct OverviewWidgetKit: Widget {
    let kind: String = OverviewWidgetID

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind, intent: ConfigurationAppIntent.self, provider: OverviewTimelineProvider()
        ) { entry in
            OverviewWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Health Overview")
        .description("Overview of your daily health metrics and trends.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#Preview(as: .systemLarge) {
    OverviewWidgetKit()
} timeline: {
    OverviewEntry(date: .now, macrosService: nil, configuration: .smiley)
}
