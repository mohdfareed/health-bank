import SwiftUI

// MARK: - Overview Component
// ============================================================================

/// Reusable overview widget component for dashboard navigation
public struct OverviewComponent: View {
    @Environment(\.widgetDataRepository) private var repository

    public init() {}

    public var body: some View {
        Group {
            if let overviewData = repository.overviewData {
                OverviewNavigationView(data: overviewData)
            } else {
                OverviewLoadingView()
            }
        }
        .animation(.default, value: repository.overviewData)
        .animation(.default, value: repository.isLoading)
    }
}

// MARK: - Overview Navigation View
// ============================================================================

struct OverviewNavigationView: View {
    let data: OverviewData

    var body: some View {
        Section("Data") {
            NavigationLink(destination: OverviewDetailView(data: data)) {
                LabeledContent {
                    HStack {
                        if !data.calibrationStatus.isCalibrated {
                            Image.maintenance
                                .foregroundStyle(Color.calories)
                                .symbolEffect(
                                    .rotate.byLayer,
                                    options: .repeat(.continuous)
                                )
                        }
                    }
                } label: {
                    Label {
                        HStack {
                            Text("Overview")
                            if !data.calibrationStatus.isCalibrated {
                                Text("Calibrating...")
                                    .textScale(.secondary)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } icon: {
                        Image(systemName: "chart.line.text.clipboard.fill")
                            .foregroundColor(.accent)
                    }
                }
            }
        }
    }
}

// MARK: - Overview Detail View
// ============================================================================

struct OverviewDetailView: View {
    let data: OverviewData

    var body: some View {
        List {
            // Calibration Status Section
            calibrationSection

            // Budget Overview Section
            budgetSection

            // Macro Breakdown Sections
            proteinSection
            carbsSection
            fatSection
        }
        .navigationTitle("Overview")
        #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
        #endif
    }

    @ViewBuilder private var calibrationSection: some View {
        if !data.calibrationStatus.isCalibrated {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline) {
                        Image.maintenance
                            .foregroundStyle(Color.calories)
                            .symbolEffect(.rotate.byLayer, options: .repeat(.continuous))
                        Text("Maintenance calibration in progress...")
                            .font(.headline)
                    }

                    Text(
                        "At least \(data.calibrationStatus.requiredDays) days of weight and calorie data is required."
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)

                    ProgressView(value: data.calibrationStatus.calibrationProgress) {
                        Text(
                            "Progress: \(data.calibrationStatus.daysOfData)/\(data.calibrationStatus.requiredDays) days"
                        )
                        .font(.caption)
                    }
                }
                .padding(.vertical, 4)
            } header: {
                Text("Calibration Status")
            }
        }
    }

    @ViewBuilder private var budgetSection: some View {
        Section("Budget") {
            overviewValue(
                data.budget.remaining,
                title: "Remaining",
                icon: Image.calories,
                format: .calorie
            )

            overviewValue(
                data.budget.budget,
                title: "Budget",
                icon: Image.calories,
                format: .calorie
            )

            overviewValue(
                data.budget.credit,
                title: "Credit",
                icon: Image.credit,
                format: .calorie
            )

            if let trends = data.trends {
                overviewValue(
                    trends.weightTrend,
                    title: "Weight Trend",
                    icon: Image.weight,
                    format: .weightChange
                )
            }
        }
    }

    @ViewBuilder private var proteinSection: some View {
        Section("Protein") {
            macroValue(
                data.macros.protein.currentIntake,
                title: "Intake",
                icon: Image.protein,
                tint: .protein
            )

            macroValue(
                data.macros.protein.smoothedIntake,
                title: "EWMA",
                icon: Image.protein,
                tint: .protein
            )

            macroValue(
                data.macros.protein.remaining,
                title: "Remaining",
                icon: Image.protein,
                tint: .protein
            )

            macroValue(
                data.macros.protein.baseBudget,
                title: "Base Budget",
                icon: Image.protein,
                tint: .protein
            )

            macroValue(
                data.macros.protein.adjustedBudget,
                title: "Adjusted Budget",
                icon: Image.protein,
                tint: .protein
            )

            macroValue(
                data.macros.protein.credit,
                title: "Credit",
                icon: Image.protein,
                tint: .protein
            )
        }
    }

    @ViewBuilder private var carbsSection: some View {
        Section("Carbs") {
            macroValue(
                data.macros.carbs.currentIntake,
                title: "Intake",
                icon: Image.carbs,
                tint: .carbs
            )

            macroValue(
                data.macros.carbs.smoothedIntake,
                title: "EWMA",
                icon: Image.carbs,
                tint: .carbs
            )

            macroValue(
                data.macros.carbs.remaining,
                title: "Remaining",
                icon: Image.carbs,
                tint: .carbs
            )

            macroValue(
                data.macros.carbs.baseBudget,
                title: "Base Budget",
                icon: Image.carbs,
                tint: .carbs
            )

            macroValue(
                data.macros.carbs.adjustedBudget,
                title: "Adjusted Budget",
                icon: Image.carbs,
                tint: .carbs
            )

            macroValue(
                data.macros.carbs.credit,
                title: "Credit",
                icon: Image.carbs,
                tint: .carbs
            )
        }
    }

    @ViewBuilder private var fatSection: some View {
        Section("Fat") {
            macroValue(
                data.macros.fat.currentIntake,
                title: "Intake",
                icon: Image.fat,
                tint: .fat
            )

            macroValue(
                data.macros.fat.smoothedIntake,
                title: "EWMA",
                icon: Image.fat,
                tint: .fat
            )

            macroValue(
                data.macros.fat.remaining,
                title: "Remaining",
                icon: Image.fat,
                tint: .fat
            )

            macroValue(
                data.macros.fat.baseBudget,
                title: "Base Budget",
                icon: Image.fat,
                tint: .fat
            )

            macroValue(
                data.macros.fat.adjustedBudget,
                title: "Adjusted Budget",
                icon: Image.fat,
                tint: .fat
            )

            macroValue(
                data.macros.fat.credit,
                title: "Credit",
                icon: Image.fat,
                tint: .fat
            )
        }
    }

    @ViewBuilder private func overviewValue(
        _ value: Double?,
        title: String,
        icon: Image,
        format: ValueFormat
    ) -> some View {
        LabeledContent {
            if let value = value {
                HStack {
                    switch format {
                    case .calorie:
                        Text("\(Int(value)) kcal")
                    case .weightChange:
                        Text("\(value >= 0 ? "+" : "")\(value, specifier: "%.1f") kg/wk")
                            .foregroundColor(value > 0 ? .red : value < 0 ? .green : .blue)
                    }
                }
            } else {
                Text("No data")
                    .foregroundColor(.secondary)
            }
        } label: {
            HStack {
                icon.foregroundColor(.secondary)
                Text(title)
            }
        }
    }

    @ViewBuilder private func macroValue(
        _ value: Double?,
        title: String,
        icon: Image,
        tint: Color
    ) -> some View {
        LabeledContent {
            if let value = value {
                Text("\(value, specifier: "%.1f")g")
            } else {
                Text("No data")
                    .foregroundColor(.secondary)
            }
        } label: {
            HStack {
                icon.foregroundColor(tint)
                Text(title)
            }
        }
    }
}

enum ValueFormat {
    case calorie
    case weightChange
}

// MARK: - Loading View
// ============================================================================

struct OverviewLoadingView: View {
    var body: some View {
        Section("Data") {
            LabeledContent {
                ProgressView()
                    .controlSize(.small)
            } label: {
                Label {
                    Text("Overview")
                } icon: {
                    Image(systemName: "chart.line.text.clipboard.fill")
                        .foregroundColor(.accent)
                }
            }
        }
    }
}
