import SwiftUI

// MARK: - Budget Component
// ============================================================================

/// Reusable budget widget component for dashboard and WidgetKit
public struct BudgetComponent: View {
    @Environment(\.widgetDataRepository) private var repository

    let style: BudgetComponentStyle

    public init(style: BudgetComponentStyle = .dashboard) {
        self.style = style
    }

    public var body: some View {
        Group {
            if let budgetData = repository.budgetData {
                switch style {
                case .dashboard:
                    DashboardBudgetView(data: budgetData)
                case .widgetSmall:
                    SmallBudgetView(data: budgetData)
                case .widgetMedium:
                    MediumBudgetView(data: budgetData)
                }
            } else {
                BudgetLoadingView(style: style)
            }
        }
        .animation(.default, value: repository.budgetData)
        .animation(.default, value: repository.isLoading)
    }
}

// MARK: - Component Styles
// ============================================================================

public enum BudgetComponentStyle {
    case dashboard  // Full dashboard card layout
    case widgetSmall  // Compact widget layout
    case widgetMedium  // Medium widget layout
}

// MARK: - Dashboard View
// ============================================================================

struct DashboardBudgetView: View {
    let data: BudgetData

    var body: some View {
        DashboardCard(
            title: "Calories",
            icon: .calories,
            color: .calories
        ) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    CalorieContent(data: data)
                    BudgetContent(data: data)
                    CreditContent(data: data)
                }
                Spacer()
                ProgressRingView(data: data)
                    .frame(maxWidth: 80)
            }
        } destination: {
        }
    }
}

// MARK: - Widget Views
// ============================================================================

struct SmallBudgetView: View {
    let data: BudgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.orange)
                Text("Calories")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }

            // Remaining calories (main focus)
            HStack(alignment: .firstTextBaseline) {
                if let remaining = data.remaining {
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
                if let currentIntake = data.calories.currentIntake,
                    let budget = data.budget
                {
                    Text("\(Int(currentIntake)) / \(Int(budget))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding()
    }
}

struct MediumBudgetView: View {
    let data: BudgetData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.orange)
                Text("Budget")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }

            HStack(spacing: 16) {
                // Left side - numbers
                VStack(alignment: .leading, spacing: 4) {
                    CalorieContent(data: data)
                    BudgetContent(data: data)
                    if data.credit != nil {
                        CreditContent(data: data)
                    }
                }

                Spacer()

                // Right side - progress ring
                ProgressRingView(data: data)
                    .frame(width: 60, height: 60)
            }
        }
        .padding()
    }
}

// MARK: - Loading View
// ============================================================================

struct BudgetLoadingView: View {
    let style: BudgetComponentStyle

    var body: some View {
        VStack {
            Image(systemName: "chart.pie.fill")
                .font(.title)
                .foregroundColor(.secondary)
            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(style == .dashboard ? 20 : 8)
    }
}

// MARK: - Shared Content Views
// ============================================================================

struct CalorieContent: View {
    let data: BudgetData

    var body: some View {
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
}

struct BudgetContent: View {
    let data: BudgetData

    var body: some View {
        let formatter = CalorieFieldDefinition().formatter
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Image.maintenance
                .symbolEffect(
                    .rotate.byLayer,
                    options: data.calories.isValid ? .nonRepeating : .repeat(.periodic(delay: 5))
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
}

struct CreditContent: View {
    let data: BudgetData

    var body: some View {
        let formatter = CalorieFieldDefinition().formatter
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Image.credit
                .foregroundColor(.accent)
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
                .foregroundColor(credit >= 0 ? .green : .red)
            } else {
                Text("No data available")
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ProgressRingView: View {
    let data: BudgetData

    var body: some View {
        ProgressRing(
            value: data.budget ?? 1,
            progress: data.calories.currentIntake ?? 0,
            color: .calories,
            tip: data.budget ?? 1,
            tipColor: (data.credit ?? 0) >= 0 ? .green : .red,
            icon: .calories
        )
        .font(.title)
    }
}
