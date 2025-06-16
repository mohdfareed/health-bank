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
        DashboardCard(
            title: "Overview",
            icon: .appleHealth, color: .healthKit
        ) {
            if analytics != nil {
                VStack {
                    caloriesSection
                    budgetSection
                    weightSection
                    proteinSection
                }
                .padding()
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            }
        } destination: {
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

    var caloriesSection: some View {
        Section("Calories") {
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.budget?.calories.currentIntake),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("Current Intake")
                } icon: {
                    Image.calories
                }
            }
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.budget?.calories.smoothedIntake),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("EWMA Intake")
                } icon: {
                    Image.calories
                }
            }
        }
    }

    var proteinSection: some View {
        Section("Protein") {
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.protein.currentIntake),
                        definition: UnitDefinition<UnitMass>.macro
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("Current Intake")
                } icon: {
                    Image.calories
                }
            }
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.protein.smoothedIntake),
                        definition: UnitDefinition<UnitMass>.macro
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("EWMA Intake")
                } icon: {
                    Image.calories
                }
            }
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.remaining?.protein),
                        definition: UnitDefinition<UnitMass>.macro
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("Remaining")
                } icon: {
                    Image.calories
                }
            }
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.baseBudgets?.protein),
                        definition: UnitDefinition<UnitMass>.macro
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("Base Budget")
                } icon: {
                    Image.calories
                }
            }
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.budgets?.protein),
                        definition: UnitDefinition<UnitMass>.macro
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("Adjusted Budget")
                } icon: {
                    Image.calories
                }
            }
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.credits?.protein),
                        definition: UnitDefinition<UnitMass>.macro
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("Credit")
                } icon: {
                    Image.calories
                }
            }
        }
    }

    var budgetSection: some View {
        Section("Budget") {
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.budget?.remaining),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("Remaining")
                } icon: {
                    Image.calories
                }
            }
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.budget?.baseBudget),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("Base Budget")
                } icon: {
                    Image.calories
                }
            }
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.budget?.budget),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("Adjusted Budget")
                } icon: {
                    Image.calories
                }
            }
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.budget?.credit),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("Credit")
                } icon: {
                    Image.calories
                }
            }
        }
    }

    var weightSection: some View {
        Section("Maintenance") {
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.budget?.weight.maintenance),
                        definition: UnitDefinition<UnitEnergy>.calorie
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(0))
                )
            } label: {
                Label {
                    Text("Maintenance")
                } icon: {
                    Image.calories
                }
            }
            LabeledContent {
                ValueView(
                    measurement: .init(
                        baseValue: .constant(analytics?.budget?.weight.weightSlope),
                        definition: UnitDefinition<UnitMass>.weight
                    ),
                    icon: nil, tint: nil,
                    format: .number.precision(.fractionLength(2))
                )
            } label: {
                Label {
                    Text("Weight Change")
                } icon: {
                    Image.calories
                }
            }
        }
    }
}
