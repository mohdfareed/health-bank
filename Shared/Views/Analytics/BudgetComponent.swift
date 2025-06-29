import Charts
import SwiftData
import SwiftUI

// MARK: - Budget Component
// ============================================================================

/// Reusable budget component for dashboard and home-screen widgets
public struct BudgetComponent: View {
    @State private var dataService: BudgetDataService?
    private let preloadedBudgetService: BudgetService?
    private let logger = AppLogger.new(for: BudgetComponent.self)

    public init(
        adjustment: Double? = nil,
        date: Date = Date(),
        preloadedBudgetService: BudgetService? = nil
    ) {
        self.preloadedBudgetService = preloadedBudgetService

        // Only create data service if no preloaded data is provided
        if preloadedBudgetService == nil {
            self._dataService = State(
                initialValue: BudgetDataService(
                    adjustment: adjustment,
                    date: date
                ))
        } else {
            self._dataService = State(initialValue: nil)
        }
    }

    // Computed property to get the current budget service
    private var currentBudgetService: BudgetService? {
        preloadedBudgetService ?? dataService?.budgetService
    }

    private var isLoading: Bool {
        if preloadedBudgetService != nil {
            return false  // Never loading when using preloaded data
        }
        return dataService?.isLoading ?? true
    }

    public var body: some View {
        Group {
            if let budget = currentBudgetService {
                BudgetDataLayout(budget: budget)
            } else {
                ProgressView().frame(maxWidth: .infinity, minHeight: 100)
            }
        }
        .animation(.default, value: currentBudgetService != nil)
        .animation(.default, value: isLoading)
        .onAppear {
            // Only start observing if using data service (not preloaded data)
            if preloadedBudgetService == nil {
                dataService?.startObserving(widgetId: "BudgetComponent")
            }
        }
        .onDisappear {
            // Only stop observing if using data service
            if preloadedBudgetService == nil {
                dataService?.stopObserving(widgetId: "BudgetComponent")
            }
        }
        .task {
            // Only refresh if using data service (not preloaded data)
            if preloadedBudgetService == nil {
                await dataService?.refresh()
            }
        }
    }
}

// MARK: - Content Views
// ============================================================================

/// Shared data layout for both dashboard and widget
private struct BudgetDataLayout: View {
    let budget: BudgetService
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallBudgetLayout(budget: budget)
        case .systemMedium:
            MediumBudgetLayout(budget: budget).padding()
        default:
            // Default to medium layout for dashboard and other contexts
            MediumBudgetLayout(budget: budget)
        }
    }
}

/// Medium widget and dashboard layout with progress ring
private struct MediumBudgetLayout: View {
    let budget: BudgetService

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                CalorieContent(data: budget)
                BudgetContent(data: budget)
                CreditContent(data: budget)
            }
            Spacer()
            ProgressRing(
                value: budget.baseBudget ?? 0,
                progress: budget.calories.currentIntake ?? 0,
                threshold: budget.budget ?? 0,
                color: .calories,
                thresholdColor: budget.credit ?? 0 >= 0 ? .green : .red,
                icon: Image.calories
            )
            .frame(maxWidth: 80)
        }
    }
}

/// Small widget layout without progress ring
private struct SmallBudgetLayout: View {
    let budget: BudgetService

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    ProgressRing(
                        value: budget.baseBudget ?? 0,
                        progress: budget.calories.currentIntake ?? 0,
                        threshold: budget.budget ?? 0,
                        color: .calories,
                        thresholdColor: budget.credit ?? 0 >= 0 ? .green : .red,
                        icon: Image.calories
                    )
                    .frame(maxWidth: 60)
                }
                Spacer()

                Text(budget.remaining ?? 0, format: CalorieFieldDefinition().formatter)
                    .fontWeight(.bold)
                    .font(.title)
                    .foregroundColor(budget.remaining ?? 0 >= 0 ? .primary : .red)
                    .contentTransition(.numericText(value: budget.remaining ?? 0))
                CreditContent(data: budget)
            }
            Spacer()
        }
    }
}

@MainActor @ViewBuilder
private func CalorieContent(data: BudgetService) -> some View {
    let formatter = CalorieFieldDefinition().formatter
    HStack(alignment: .firstTextBaseline, spacing: 0) {
        ValueView(
            measurement: .init(
                baseValue: .constant(data.remaining),
                definition: UnitDefinition<UnitEnergy>.calorie
            ),
            icon: nil, tint: nil, format: formatter
        )
        .fontWeight(.bold)
        .font(.title)
        .foregroundColor(data.remaining ?? 0 >= 0 ? .primary : .red)
        .contentTransition(.numericText(value: data.remaining ?? 0))
    }
}

@MainActor @ViewBuilder
private func BudgetContent(data: BudgetService) -> some View {
    let formatter = CalorieFieldDefinition().formatter
    HStack(alignment: .firstTextBaseline, spacing: 0) {
        Image.maintenance
            .symbolEffect(
                .rotate.byLayer,
                options: data.isValid && data.weight.isValid
                    ? .nonRepeating
                    : .repeat(.periodic(delay: 5))
            )
            .foregroundColor(.calories)
            .font(.subheadline)
            .frame(width: 18, height: 18, alignment: .center)
            .padding(.trailing, 8)

        Text(data.calories.currentIntake ?? 0, format: formatter)
            .fontWeight(.bold)
            .font(.headline)
            .foregroundColor(.secondary)
            .contentTransition(
                .numericText(
                    value: data.calories.currentIntake ?? 0)
            )

        Text("/")
            .font(.headline)
            .foregroundColor(.secondary)

        ValueView(
            measurement: .init(
                baseValue: .constant(data.budget),
                definition: UnitDefinition<UnitEnergy>.calorie
            ),
            icon: nil, tint: nil, format: formatter
        )
        .fontWeight(.bold)
        .font(.headline)
        .foregroundColor(.secondary)
        .contentTransition(.numericText(value: data.budget ?? 0))
    }
}

@MainActor @ViewBuilder
private func CreditContent(data: BudgetService) -> some View {
    let formatter = CalorieFieldDefinition().formatter
    HStack(alignment: .firstTextBaseline, spacing: 0) {
        Image.credit
            .foregroundColor(data.credit ?? 0 >= 0 ? .green : .red)
            .font(.headline)
            .frame(width: 18, height: 18, alignment: .center)
            .padding(.trailing, 8)

        if let credit = data.credit {
            ValueView(
                measurement: .init(
                    baseValue: .constant(credit),
                    definition: UnitDefinition<UnitEnergy>.calorie
                ),
                icon: nil, tint: nil, format: formatter
            )
            .fontWeight(.bold)
            .font(.headline)
            .foregroundColor(.secondary)
            .contentTransition(.numericText(value: credit))
        } else {
            Text("No data available")
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
}
