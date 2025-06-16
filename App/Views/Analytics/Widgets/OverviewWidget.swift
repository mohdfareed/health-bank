import Charts
import SwiftData
import SwiftUI

// MARK: - Budget Overview Widget
// ============================================================================

struct OverviewWidget: View {
    @MacrosAnalytics var analytics: MacrosAnalyticsService?
    @Binding var refreshing: Bool

    init(
        _ adjustment: Double? = nil,
        _ macroAdjustments: CalorieMacros? = nil,
        refreshing: Binding<Bool> = .constant(false)
    ) {
        self._refreshing = refreshing
        self._analytics = .init(
            budgetAnalytics: .init(adjustment: adjustment),
            adjustments: macroAdjustments
        )
    }

    var body: some View {
        NavigationLink(
            destination: overviewPage
        ) {
            Label {
                Text("Overview")
            } icon: {
                Image(systemName: "chart.line.text.clipboard.fill")
            }
        }
    }

    @ViewBuilder var overviewPage: some View {
        NavigationStack {
            List {
                if analytics != nil {
                    overviewSections
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 100)
                }
            }
            .navigationTitle("Overview")
            .refreshable {
                refreshing.toggle()
            }
        }

        .animation(.default, value: refreshing)
        .animation(.default, value: analytics == nil)

        .onAppear {
            Task {
                await $analytics.reload(at: Date())
            }
        }

        .onChange(of: refreshing) {
            Task {
                await $analytics.reload(at: Date())
            }
        }
    }

    @ViewBuilder var overviewSections: some View {
        Section("Calories") {
            calorieValue(
                analytics?.budget?.calories.currentIntake,
                title: "Intake",
                icon: Image.calories
            )
            calorieValue(
                analytics?.budget?.calories.smoothedIntake,
                title: "EWMA",
                icon: Image.calories
            )
        }

        Section("Maintenance") {
            calorieValue(
                analytics?.budget?.weight.maintenance,
                title: "Maintenance",
                icon: Image.calories
            )
            weightValue(
                analytics?.budget?.weight.weightSlope,
                title: "Change",
                icon: Image.weight
            )
        }

        Section("Budget") {
            calorieValue(
                analytics?.budget?.remaining,
                title: "Remaining",
                icon: Image.calories
            )

            calorieValue(
                analytics?.budget?.baseBudget,
                title: "Base",
                icon: Image.calories
            )

            calorieValue(
                analytics?.budget?.budget,
                title: "Adjusted",
                icon: Image.calories
            )

            calorieValue(
                analytics?.budget?.credit,
                title: "Credit",
                icon: Image.calories
            )
        }

        Section("Protein") {
            proteinSection
        }
    }

    @ViewBuilder var proteinSection: some View {
        macroValue(
            analytics?.protein.currentIntake,
            title: "Intake",
            icon: Image.protein, tint: .protein
        )

        macroValue(
            analytics?.protein.smoothedIntake,
            title: "EWMA",
            icon: Image.protein, tint: .protein
        )

        macroValue(
            analytics?.remaining?.protein,
            title: "Remaining",
            icon: Image.protein, tint: .protein
        )

        macroValue(
            analytics?.baseBudgets?.protein,
            title: "Base",
            icon: Image.protein, tint: .protein
        )

        macroValue(
            analytics?.budgets?.protein,
            title: "Adjusted",
            icon: Image.protein, tint: .protein
        )

        macroValue(
            analytics?.credits?.protein,
            title: "Credit",
            icon: Image.protein, tint: .protein
        )
    }

    private func calorieValue(
        _ value: Double?,
        title: String.LocalizationValue,
        icon: Image? = nil
    ) -> some View {
        MeasurementField(
            validator: nil, format: CalorieFieldDefinition().formatter,
            showPicker: true,
            measurement: .init(
                baseValue: .constant(value),
                definition: UnitDefinition<UnitEnergy>.calorie
            ),
        ) {
            DetailedRow(image: icon, tint: .calories) {
                Text(String(localized: title))
            } subtitle: {
            } details: {
            }
        }
        .disabled(true)
    }

    private func macroValue(
        _ value: Double?,
        title: String.LocalizationValue,
        icon: Image? = nil, tint: Color? = nil
    ) -> some View {
        MeasurementField(
            validator: nil, format: ProteinFieldDefinition().formatter,
            showPicker: true,
            measurement: .init(
                baseValue: .constant(value),
                definition: UnitDefinition<UnitMass>.macro
            ),
        ) {
            DetailedRow(image: icon, tint: tint) {
                Text(String(localized: title))
            } subtitle: {
            } details: {
            }
        }
        .disabled(true)
    }

    @ViewBuilder private func weightValue(
        _ value: Double?,
        title: String.LocalizationValue,
        icon: Image? = nil
    ) -> some View {
        MeasurementField(
            validator: nil, format: WeightFieldDefinition().formatter,
            showPicker: true,
            measurement: .init(
                baseValue: .constant(value),
                definition: UnitDefinition<UnitMass>.weight
            ),
        ) {
            DetailedRow(image: icon, tint: .weight) {
                Text(String(localized: title))
            } subtitle: {
            } details: {
            }
        }
        .disabled(true)
    }
}
