import HealthVaultsShared
import SwiftData
import SwiftUI
import WidgetKit

// MARK: - Macros Widget
// ============================================================================

struct MacrosWidget: Widget {
    let kind: String = MacrosWidgetID

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: MacrosTimelineProvider()
        ) { entry in
            MacrosWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(URL(string: "healthvaults://dashboard"))
        }
        .configurationDisplayName("Macros")
        .description("Track your daily macronutrient intake")
        .supportedFamilies([.systemMedium])
    }
}

struct MacrosWidgetEntryView: View {
    var entry: MacrosEntry

    var body: some View {
        if let macrosService = entry.macrosService {
            MacrosComponent(
                date: entry.date,
                preloadedMacrosService: macrosService
            )
        } else {
            Text("Loading...")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Macros Timeline Provider
// ============================================================================

struct MacrosTimelineProvider: AppIntentTimelineProvider {
    @AppStorage(.userGoals) private var goalsID: UUID

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
        // Get current macros and adjustment from UserGoals using shared helper
        let goals = await WidgetsSettings.getGoals(for: goalsID)

        // Create the data services with proper coordination
        let budgetDataService = BudgetDataService(
            adjustment: goals?.adjustment,
            date: date
        )

        let macrosDataService = MacrosDataService(
            adjustments: goals?.macros,
            date: date
        )

        // Load the data in proper order
        await budgetDataService.refresh()
        await macrosDataService.refresh()

        return MacrosEntry(
            date: date,
            macrosService: macrosDataService.macrosService,
            configuration: configuration
        )
    }
}

struct MacrosEntry: TimelineEntry, Sendable {
    let date: Date
    let macrosService: MacrosAnalyticsService?
    let configuration: ConfigurationAppIntent
}
