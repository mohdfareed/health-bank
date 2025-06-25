import SwiftUI

// MARK: - Macros Component
// ============================================================================

/// Reusable macros widget component for dashboard and WidgetKit
public struct MacrosComponent: View {
    @Environment(\.widgetDataRepository) private var repository

    let style: MacrosComponentStyle

    public init(style: MacrosComponentStyle = .dashboard) {
        self.style = style
    }

    public var body: some View {
        Group {
            if let macrosData = repository.macrosData {
                switch style {
                case .dashboard:
                    DashboardMacrosView(data: macrosData)
                case .widgetSmall:
                    SmallMacrosView(data: macrosData)
                case .widgetMedium:
                    MediumMacrosView(data: macrosData)
                }
            } else {
                MacrosLoadingView(style: style)
            }
        }
        .animation(.default, value: repository.macrosData)
        .animation(.default, value: repository.isLoading)
    }
}

// MARK: - Component Styles
// ============================================================================

public enum MacrosComponentStyle {
    case dashboard  // Full dashboard card layout
    case widgetSmall  // Compact widget layout
    case widgetMedium  // Medium widget layout
}

// MARK: - Dashboard View
// ============================================================================

struct DashboardMacrosView: View {
    let data: MacrosData

    var body: some View {
        HStack(spacing: 16) {
            MacroRingView(
                nutrient: data.protein,
                name: "Protein",
                color: .protein,
                icon: .protein
            )

            MacroRingView(
                nutrient: data.carbs,
                name: "Carbs",
                color: .carbs,
                icon: .carbs
            )

            MacroRingView(
                nutrient: data.fat,
                name: "Fat",
                color: .fat,
                icon: .fat
            )
        }
    }
}

// MARK: - Widget Views
// ============================================================================

struct SmallMacrosView: View {
    let data: MacrosData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.orange)
                Text("Macros")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }

            // Show primary macro (protein)
            HStack(alignment: .firstTextBaseline) {
                if let remaining = data.protein.remaining {
                    Text("\(Int(remaining))g")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(remaining >= 0 ? .primary : .red)
                    Text("protein left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("---")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            // Progress summary
            HStack(spacing: 4) {
                MacroProgressSummary(nutrient: data.protein, color: .protein, abbreviation: "P")
                MacroProgressSummary(nutrient: data.carbs, color: .carbs, abbreviation: "C")
                MacroProgressSummary(nutrient: data.fat, color: .fat, abbreviation: "F")
                Spacer()
            }
        }
        .padding()
    }
}

struct MediumMacrosView: View {
    let data: MacrosData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(.orange)
                Text("Macros")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }

            HStack(spacing: 12) {
                MacroRingView(
                    nutrient: data.protein,
                    name: "P",
                    color: .protein,
                    icon: .protein,
                    compact: true
                )

                MacroRingView(
                    nutrient: data.carbs,
                    name: "C",
                    color: .carbs,
                    icon: .carbs,
                    compact: true
                )

                MacroRingView(
                    nutrient: data.fat,
                    name: "F",
                    color: .fat,
                    icon: .fat,
                    compact: true
                )
            }
        }
        .padding()
    }
}

// MARK: - Shared Content Views
// ============================================================================

struct MacroRingView: View {
    let nutrient: MacroNutrient
    let name: String
    let color: Color
    let icon: Image
    let compact: Bool

    init(nutrient: MacroNutrient, name: String, color: Color, icon: Image, compact: Bool = false) {
        self.nutrient = nutrient
        self.name = name
        self.color = color
        self.icon = icon
        self.compact = compact
    }

    var body: some View {
        VStack(alignment: .center, spacing: compact ? 4 : 8) {
            if !compact {
                // Remaining amount
                if let remaining = nutrient.remaining {
                    Text("\(Int(remaining))g")
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

            // Progress info
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                if let current = nutrient.currentIntake,
                    let budget = nutrient.adjustedBudget
                {
                    Text("\(Int(current))")
                        .font(compact ? .caption : .subheadline)
                        .fontWeight(.medium)
                    Text("/")
                        .font(compact ? .caption : .subheadline)
                        .foregroundColor(.secondary)
                    Text("\(Int(budget))")
                        .font(compact ? .caption : .subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("No data")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Progress ring
            ProgressRing(
                value: nutrient.adjustedBudget ?? 1,
                progress: nutrient.currentIntake ?? 0,
                color: color,
                tip: nutrient.adjustedBudget ?? 1,
                tipColor: (nutrient.credit ?? 0) >= 0 ? .green : .red,
                icon: icon
            )
            .frame(width: compact ? 40 : 60, height: compact ? 40 : 60)
            .font(compact ? .caption : .subheadline)

            if !compact {
                Text(name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct MacroProgressSummary: View {
    let nutrient: MacroNutrient
    let color: Color
    let abbreviation: String

    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(abbreviation)
                .font(.caption2)
                .foregroundColor(.secondary)

            if let current = nutrient.currentIntake,
                let budget = nutrient.adjustedBudget
            {
                Text("\(Int(current))/\(Int(budget))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Loading View
// ============================================================================

struct MacrosLoadingView: View {
    let style: MacrosComponentStyle

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
