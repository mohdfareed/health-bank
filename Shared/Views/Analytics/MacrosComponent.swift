import Charts
import SwiftData
import SwiftUI

// MARK: - Macros Component
// ============================================================================

/// Reusable macros component for dashboard and homescreen widgets
public struct MacrosComponent: View {
    @State private var budgetDataService: BudgetDataService?
    @State private var macrosDataService: MacrosDataService?

    private let preloadedMacrosService: MacrosAnalyticsService?
    private let macroAdjustments: CalorieMacros?
    private let date: Date
    private let logger = AppLogger.new(for: MacrosComponent.self)

    public init(
        adjustment: Double? = nil,
        macroAdjustments: CalorieMacros? = nil,
        date: Date = Date(),
        preloadedMacrosService: MacrosAnalyticsService? = nil
    ) {
        self.preloadedMacrosService = preloadedMacrosService
        self.macroAdjustments = macroAdjustments
        self.date = date

        // Only create data services if no preloaded data is provided
        if preloadedMacrosService == nil {
            self._budgetDataService = State(
                initialValue: BudgetDataService(
                    adjustment: adjustment,
                    date: date
                ))

            self._macrosDataService = State(
                initialValue: MacrosDataService(
                    adjustments: macroAdjustments,
                    date: date
                ))
        } else {
            self._budgetDataService = State(initialValue: nil)
            self._macrosDataService = State(initialValue: nil)
        }
    }

    // Computed property to get the current macros service
    private var currentMacrosService: MacrosAnalyticsService? {
        preloadedMacrosService ?? macrosDataService?.macrosService
    }

    private var isLoading: Bool {
        if preloadedMacrosService != nil {
            return false  // Never loading when using preloaded data
        }
        return macrosDataService?.isLoading ?? budgetDataService?.isLoading ?? true
    }

    public var body: some View {
        Group {
            if let macros = currentMacrosService {
                MacrosDataLayout(macros: macros)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        }
        .animation(.default, value: currentMacrosService != nil)
        .animation(.default, value: isLoading)

        .onAppear {
            logger.debug("MacrosComponent appeared")
            macrosDataService?.startObserving()
            budgetDataService?.startObserving()
        }
        .onDisappear {
            // Only stop observing if using data services
            if preloadedMacrosService == nil {
                budgetDataService?.stopObserving()
                macrosDataService?.stopObserving()
                logger.debug("MacrosComponent disappeared, stopped observing")
            }
        }
        .task {
            // Only refresh if using data services (not preloaded data)
            if preloadedMacrosService == nil {
                logger.debug("MacrosComponent: Starting data refresh")

                // Refresh budget data first
                await budgetDataService?.refresh()
                logger.debug("MacrosComponent: Budget data refreshed")

                // Once budget is loaded, recreate macros service with budget dependency
                if let budgetService = budgetDataService?.budgetService {
                    logger.debug(
                        "MacrosComponent: Creating MacrosDataService with budget dependency")
                    let newMacrosDataService = MacrosDataService(
                        budgetService: budgetService,
                        adjustments: macroAdjustments,
                        date: date
                    )
                    macrosDataService = newMacrosDataService

                    // Now refresh macros with budget context
                    await macrosDataService?.refresh()
                    logger.debug("MacrosComponent: Macros data refreshed with budget context")
                } else {
                    logger.warning(
                        "MacrosComponent: Budget service failed to load, cannot create macros service"
                    )
                }
            }
        }
    }
}

// MARK: - Content Views
// ============================================================================

/// Shared data layout for both dashboard and widget
private struct MacrosDataLayout: View {
    let macros: MacrosAnalyticsService

    var body: some View {
        HStack {
            MacroBudgetContent(macros: macros, ring: .protein)
            Spacer()
            Divider()
            Spacer()
            MacroBudgetContent(macros: macros, ring: .carbs)
            Spacer()
            Divider()
            Spacer()
            MacroBudgetContent(macros: macros, ring: .fat)
        }
    }
}

// MARK: - Macro Data Content Views
// ============================================================================

@MainActor
private struct MacroBudgetContent: View {
    let macros: MacrosAnalyticsService
    let ring: MacrosAnalyticsService.MacroRing

    var body: some View {
        let formatter = ProteinFieldDefinition().formatter
        VStack(alignment: .center) {
            ValueView(
                measurement: .init(
                    baseValue: .constant(remaining(ring: ring)),
                    definition: UnitDefinition<UnitMass>.macro
                ),
                icon: nil, tint: nil, format: formatter
            )
            .fontWeight(.bold)
            .font(.title)
            .foregroundColor(remaining(ring: ring) ?? 0 >= 0 ? .primary : .red)
            .contentTransition(.numericText(value: remaining(ring: ring) ?? 0))

            MacroContent(ring: ring)

            // Use ProgressRing instead of macros.progress(ring)
            ProgressRing(
                value: baseBudget(ring: ring) ?? 0,
                progress: intake(ring: ring) ?? 0,
                color: color(ring: ring),
                tip: budget(ring: ring) ?? 0,
                tipColor: credit(ring: ring) ?? 0 >= 0 ? .green : .red,
                icon: icon(ring: ring)
            )
            .font(.subheadline)
            .frame(maxWidth: 50)
        }
    }

    @MainActor @ViewBuilder
    private func MacroContent(ring: MacrosAnalyticsService.MacroRing) -> some View {
        let formatter = ProteinFieldDefinition().formatter
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(intake(ring: ring) ?? 0, format: formatter)
                .fontWeight(.bold)
                .font(.headline)
                .foregroundColor(.secondary)
                .contentTransition(.numericText(value: intake(ring: ring) ?? 0))

            Text("/")
                .font(.headline)
                .foregroundColor(.secondary)

            ValueView(
                measurement: .init(
                    baseValue: .constant(budget(ring: ring)),
                    definition: UnitDefinition<UnitMass>.macro
                ),
                icon: nil, tint: nil, format: formatter
            )
            .fontWeight(.bold)
            .font(.headline)
            .foregroundColor(.secondary)
            .contentTransition(.numericText(value: budget(ring: ring) ?? 0))
        }
    }

    private func intake(ring: MacrosAnalyticsService.MacroRing) -> Double? {
        switch ring {
        case .protein:
            return macros.protein.currentIntake
        case .carbs:
            return macros.carbs.currentIntake
        case .fat:
            return macros.fat.currentIntake
        }
    }

    private func budget(ring: MacrosAnalyticsService.MacroRing) -> Double? {
        switch ring {
        case .protein:
            return macros.budgets?.protein
        case .carbs:
            return macros.budgets?.carbs
        case .fat:
            return macros.budgets?.fat
        }
    }

    private func remaining(ring: MacrosAnalyticsService.MacroRing) -> Double? {
        switch ring {
        case .protein:
            return macros.remaining?.protein
        case .carbs:
            return macros.remaining?.carbs
        case .fat:
            return macros.remaining?.fat
        }
    }

    private func baseBudget(ring: MacrosAnalyticsService.MacroRing) -> Double? {
        switch ring {
        case .protein:
            return macros.baseBudgets?.protein
        case .carbs:
            return macros.baseBudgets?.carbs
        case .fat:
            return macros.baseBudgets?.fat
        }
    }

    private func credit(ring: MacrosAnalyticsService.MacroRing) -> Double? {
        switch ring {
        case .protein:
            return macros.credits?.protein
        case .carbs:
            return macros.credits?.carbs
        case .fat:
            return macros.credits?.fat
        }
    }

    private func icon(ring: MacrosAnalyticsService.MacroRing) -> Image? {
        switch ring {
        case .protein:
            return .protein
        case .carbs:
            return .carbs
        case .fat:
            return .fat
        }
    }

    private func color(ring: MacrosAnalyticsService.MacroRing) -> Color {
        switch ring {
        case .protein:
            return .protein
        case .carbs:
            return .carbs
        case .fat:
            return .fat
        }
    }
}
