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
            logger.debug("BudgetComponent appeared")
        }
        .onDisappear {
            logger.debug("BudgetComponent disappeared")
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

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                CalorieContent(data: budget)
                BudgetContent(data: budget)
                CreditContent(data: budget)
            }
            Spacer()
            ProgressRing(
                value: budget.remaining ?? 0,
                progress: budget.budget ?? 0,
                color: .calories,
                tip: nil,
                tipColor: nil,
                icon: Image(systemName: "flame.fill")
            )
            .font(.title)
            .frame(maxWidth: 80)
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
    }
}

@MainActor @ViewBuilder
private func BudgetContent(data: BudgetService) -> some View {
    let formatter = CalorieFieldDefinition().formatter
    HStack(alignment: .firstTextBaseline, spacing: 0) {
        Image.maintenance
            .symbolEffect(
                .rotate.byLayer,
                options: data.isValid
                    ? .nonRepeating
                    : .repeat(.periodic(delay: 5))
            )
            .foregroundColor(.calories)
            .font(.subheadline)
            .frame(width: 24, height: 24, alignment: .leading)

        Text(data.calories.currentIntake ?? 0, format: formatter)
            .fontWeight(.bold)
            .font(.headline)
            .foregroundColor(.secondary)

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
    }
}

@MainActor @ViewBuilder
private func CreditContent(data: BudgetService) -> some View {
    let formatter = CalorieFieldDefinition().formatter
    HStack(alignment: .firstTextBaseline, spacing: 0) {
        Image.credit
            .foregroundColor(data.credit ?? 0 >= 0 ? .green : .red)
            .font(.headline)
            .frame(width: 24, height: 24, alignment: .leading)

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
        } else {
            Text("No data available")
                .fontWeight(.bold)
                .foregroundColor(.secondary)
        }
    }
}
