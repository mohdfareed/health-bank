import Charts
import SwiftData
import SwiftUI

// MARK: - Budget Overview Widget
// ============================================================================

public struct OverviewWidget: View {
    @MacrosAnalytics var analytics: MacrosAnalyticsService?

    public init(analytics: MacrosAnalytics) {
        self._analytics = analytics
    }

    public var body: some View {
        Section("Data") {
            NavigationLink(
                destination: overviewPage
            ) {
                LabeledContent {
                    HStack {
                        if analytics?.budget?.weight.isValid != true {
                            Image.maintenance.foregroundStyle(Color.calories)
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
                            if analytics?.budget?.weight.isValid != true
                                || analytics?.budget?.calories.isValid != true
                            {
                                Text("Calibrating...")
                                    .textScale(.secondary)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } icon: {
                        Image(systemName: "chart.line.text.clipboard.fill")
                    }
                }
            }
        }
        // Auto-refresh when any nutrition data changes
        .refreshOnHealthDataChange(for: [.dietaryCalories, .protein, .carbs, .fat, .bodyMass]) {
            await $analytics.reload(at: Date())
        }
    }

    @ViewBuilder var overviewPage: some View {
        NavigationStack {
            List {
                if analytics != nil {
                    overviewSections
                    macrosPage
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 100)
                }
            }
            .navigationTitle("Overview")

            .refreshable {
                await refresh()
            }
            .onAppear {
                Task {
                    await refresh()
                }
            }
        }
        .animation(.default, value: analytics == nil)
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

        Section {
            weightValue(
                analytics?.budget?.weight.weightSlope,
                title: "Change",
                icon: Image.weight
            )
            calorieValue(
                analytics?.budget?.weight.maintenance,
                title: "Maintenance",
                icon: Image.calories
            )
        } header: {
            Text("Maintenance")
        } footer: {
            if analytics?.budget?.weight.isValid != true {
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Image.maintenance.foregroundStyle(Color.calories)
                            .symbolEffect(
                                .rotate.byLayer,
                                options: .repeat(.continuous)
                            )
                        Text("Maintenance calibration in progress...")
                    }
                    Text("At least 14 days of weight and calorie data is required.")
                }
            }
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

    }

    @ViewBuilder var macrosPage: some View {
        Section {
            NavigationLink(
                destination: NavigationStack {
                    List {
                        proteinSection
                    }
                    .refreshable {
                        await refresh()
                    }
                    .onAppear {
                        Task {
                            await refresh()
                        }
                    }
                }
                .navigationTitle("Protein")
            ) {
                DetailedRow(image: Image.protein, tint: .protein) {
                    Text("Protein")
                } subtitle: {
                } details: {
                }
            }

            NavigationLink(
                destination: NavigationStack {
                    List {
                        carbsSection
                    }
                    .refreshable {
                        await refresh()
                    }
                    .onAppear {
                        Task {
                            await refresh()
                        }
                    }
                }
                .navigationTitle("Carbohydrates")
            ) {
                DetailedRow(image: Image.carbs, tint: .carbs) {
                    Text("Carbs")
                } subtitle: {
                } details: {
                }
            }

            NavigationLink(
                destination: NavigationStack {
                    List {
                        fatSection
                    }
                    .refreshable {
                        await refresh()
                    }
                    .onAppear {
                        Task {
                            await refresh()
                        }
                    }
                }
                .navigationTitle("Fat")
            ) {
                DetailedRow(image: Image.fat, tint: .fat) {
                    Text("Fat")
                } subtitle: {
                } details: {
                }
            }
        } header: {
            Text("Macros")
        } footer: {
            Text(
                "Macros are calculated based on the calorie budget."
            )
        }
    }

    @ViewBuilder var proteinSection: some View {
        Section("Protein") {
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
        }

        Section("Budget") {
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
    }

    @ViewBuilder var carbsSection: some View {
        Section("Carbs") {
            macroValue(
                analytics?.carbs.currentIntake,
                title: "Intake",
                icon: Image.carbs, tint: .carbs
            )

            macroValue(
                analytics?.carbs.smoothedIntake,
                title: "EWMA",
                icon: Image.carbs, tint: .carbs
            )
        }

        Section("Budget") {
            macroValue(
                analytics?.remaining?.carbs,
                title: "Remaining",
                icon: Image.carbs, tint: .carbs
            )

            macroValue(
                analytics?.baseBudgets?.carbs,
                title: "Base",
                icon: Image.carbs, tint: .carbs
            )

            macroValue(
                analytics?.budgets?.carbs,
                title: "Adjusted",
                icon: Image.carbs, tint: .carbs
            )

            macroValue(
                analytics?.credits?.carbs,
                title: "Credit",
                icon: Image.carbs, tint: .carbs
            )
        }
    }

    @ViewBuilder var fatSection: some View {
        Section("Fat") {
            macroValue(
                analytics?.fat.currentIntake,
                title: "Intake",
                icon: Image.fat, tint: .fat
            )

            macroValue(
                analytics?.fat.smoothedIntake,
                title: "EWMA",
                icon: Image.fat, tint: .fat
            )
        }

        Section("Budget") {
            macroValue(
                analytics?.remaining?.fat,
                title: "Remaining",
                icon: Image.fat, tint: .fat
            )

            macroValue(
                analytics?.baseBudgets?.fat,
                title: "Base",
                icon: Image.fat, tint: .fat
            )

            macroValue(
                analytics?.budgets?.fat,
                title: "Adjusted",
                icon: Image.fat, tint: .fat
            )

            macroValue(
                analytics?.credits?.fat,
                title: "Credit",
                icon: Image.fat, tint: .fat
            )
        }
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

    func refresh() async {
        await $analytics.reload(at: Date())
    }
}
