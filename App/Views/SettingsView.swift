import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage(.dailyCalorieBudget)
    var budgetID: CalorieBudget.ID

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(String(localized: "General Settings"))) {
                    GeneralSettings()
                    LocalizationSettings()
                }

                Section(header: Text(String(localized: "Daily Calorie Budget"))) {
                    DailyBudgetSettings(budget: .init(self.budgetID))
                }

                NavigationLink(destination: BudgetsHistory()) {
                    Text(String(localized: "Budget History"))
                }

                Button(
                    String(localized: "Reset All Settings"),
                    role: .destructive
                ) { UserDefaults.standard.resetSettings() }
            }
            .navigationTitle(String(localized: "Settings"))
        }
    }
}

private struct GeneralSettings: View {
    @AppStorage(.theme) var theme: AppTheme
    @AppStorage(.notifications) var notifications: Bool?
    @AppStorage(.biometrics) var biometrics: Bool?

    var body: some View {
        Picker(
            String(localized: "Theme"), systemImage: "paintbrush",
            selection: self.$theme,
            content: {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Text(theme.localized).tag(theme)
                }
            }
        ) {
            Label(
                self.theme.localized, systemImage: ""
            ).labelStyle(.titleOnly)
        }
        .pickerStyle(.automatic)

        Toggle(isOn: self.$notifications.defaulted(to: false)) {
            Label(
                String(localized: "Enable notifications"),
                systemImage: "bell"
            ).labelStyle(.automatic)
        }

        Toggle(isOn: self.$biometrics.defaulted(to: false)) {
            Label(
                String(localized: "Enable biometrics"),
                systemImage: "faceid"
            ).labelStyle(.automatic)
        }
    }
}

private struct LocalizationSettings: View {
    @AppLocale() var locale: Locale

    var body: some View {
        Picker(
            String(localized: "Measurements"), systemImage: "ruler",
            selection: self.$locale.units,
            content: {
                let systems = MeasurementSystem.measurementSystems
                ForEach(systems, id: \.self) { system in
                    Text(system.localized).tag(system)
                }
            },
        ) {
            Label(
                self.locale.measurementSystem.localized, systemImage: ""
            ).labelStyle(.titleOnly)
        }

        Picker(
            String(localized: "First Weekday"), systemImage: "calendar",
            selection: self.$locale.firstWeekDay,
            content: {
                ForEach(Weekday.allCases, id: \.self) { weekday in
                    Text(weekday.localized).tag(weekday)
                }
            }
        ) {
            Label(
                self.locale.firstDayOfWeek.abbreviated, systemImage: ""
            ).labelStyle(.titleOnly)
        }
    }
}

private struct DailyBudgetSettings: View {
    @Query.Singleton var budget: CalorieBudget
    var body: some View {
        Form {
            Section(header: Text(String(localized: "Daily Budget"))) {
                DatePicker(
                    String(localized: "Date"),
                    selection: self.$budget.date,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)

                Stepper(
                    String(localized: "Calories: \(self.budget.calories.formatted())"),
                    value: self.$budget.calories,
                    in: 0...10_000
                )

                if let macros = self.budget.macros {
                    Text("P: \(macros.protein ?? 0) F: \(macros.fat ?? 0) C: \(macros.carbs ?? 0)")
                        .font(.caption)
                }
            }
        }
        .navigationTitle(String(localized: "Daily Budget"))
    }
}

private struct BudgetsHistory: View {
    @Query var budgets: [CalorieBudget]
    var body: some View {
        NavigationView {
            List(self.budgets) { budget in
                NavigationLink(value: budget) {
                    DataRow(
                        title: Text(budget.date.formatted()),
                        subtitle: Text(budget.calories.formatted()),
                        image: Image(systemName: "calendar"),
                        color: .primary
                    ) {
                        Text(budget.calories.formatted())
                    }
                }
            }
            .navigationTitle(String(localized: "Calorie Budgets"))
            .navigationDestination(for: CalorieBudget.self) { budget in
                VStack {
                    Text(budget.date.formatted())
                        .font(.headline)
                    Text(budget.calories.formatted())
                        .font(.subheadline)
                    if let macros = budget.macros {
                        Text(
                            "P: \(macros.protein ?? 0) F: \(macros.fat ?? 0) C: \(macros.carbs ?? 0)"
                        )
                        .font(.caption)
                    }
                }
                .padding()
            }
        }
    }
}
