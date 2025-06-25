import HealthVaultsShared
import SwiftUI
import WidgetKit

struct BudgetTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> BudgetEntry {
        BudgetEntry(date: Date(), budgetData: nil, configuration: ConfigurationAppIntent())
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
        // Use the new unified data service
        let dataService = WidgetDataService()
        let budgetData = await dataService.fetchBudgetData(for: date)

        return BudgetEntry(
            date: date,
            budgetData: budgetData,
            configuration: configuration
        )
    }
}

struct BudgetEntry: TimelineEntry, Sendable {
    let date: Date
    let budgetData: BudgetData?
    let configuration: ConfigurationAppIntent
}

struct BudgetWidgetEntryView: View {
    var entry: BudgetTimelineProvider.Entry

    var body: some View {
        if let budgetData = entry.budgetData {
            // Use the unified BudgetComponent for widget
            BudgetComponent(style: .widgetSmall)
                .onAppear {
                    // Populate the shared repository with widget data
                    Task { @MainActor in
                        WidgetDataRepository.shared.updateBudgetData(budgetData)
                    }
                }
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
    BudgetEntry(date: .now, budgetData: nil, configuration: .smiley)
}

// MARK: - Macros Widget
// ============================================================================

struct MacrosTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> MacrosEntry {
        MacrosEntry(date: Date(), macrosData: nil, configuration: ConfigurationAppIntent())
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
        // Use the new unified data service
        let dataService = WidgetDataService()
        let macrosData = await dataService.fetchMacrosData(for: date)

        return MacrosEntry(
            date: date,
            macrosData: macrosData,
            configuration: configuration
        )
    }
}

struct MacrosEntry: TimelineEntry, Sendable {
    let date: Date
    let macrosData: MacrosData?
    let configuration: ConfigurationAppIntent
}

struct MacrosWidgetEntryView: View {
    var entry: MacrosTimelineProvider.Entry

    var body: some View {
        if let macrosData = entry.macrosData {
            // Use the unified MacrosComponent for widget
            MacrosComponent(style: .widgetSmall)
                .onAppear {
                    // Populate the shared repository with widget data
                    Task { @MainActor in
                        WidgetDataRepository.shared.updateMacrosData(macrosData)
                    }
                }
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
    MacrosEntry(date: .now, macrosData: nil, configuration: .smiley)
}

// MARK: - Overview Widget
// ============================================================================

struct OverviewTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> OverviewEntry {
        OverviewEntry(date: Date(), overviewData: nil, configuration: ConfigurationAppIntent())
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
        // Use the new unified data service
        let dataService = WidgetDataService()
        let overviewData = await dataService.fetchOverviewData(for: date)

        return OverviewEntry(
            date: date,
            overviewData: overviewData,
            configuration: configuration
        )
    }
}

struct OverviewEntry: TimelineEntry, Sendable {
    let date: Date
    let overviewData: OverviewData?
    let configuration: ConfigurationAppIntent
}

struct OverviewWidgetEntryView: View {
    var entry: OverviewTimelineProvider.Entry

    var body: some View {
        if let overviewData = entry.overviewData {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.line.text.clipboard.fill")
                        .foregroundColor(.blue)
                    Text("Overview")
                        .font(.headline)
                        .fontWeight(.medium)
                    Spacer()
                }

                // Budget info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calories")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if let remaining = overviewData.budget.remaining {
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

                    // Simple macros summary
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Macros")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("P•C•F")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
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
    OverviewEntry(date: .now, overviewData: nil, configuration: .smiley)
}
