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

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
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
