import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage(.dailyCalorieBudget)
    var budgetID: CalorieBudget.ID

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(String(localized: "Daily Calorie Budget"))) {
                    DailyBudgetSettings(budget: .init(self.budgetID))
                }

                NavigationLink(destination: BudgetsHistory()) {
                    Text(String(localized: "Budget History"))
                }

                Section(header: Text(String(localized: "General Settings"))) {
                    GeneralSettings()
                    LocalizationSettings()
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
            String(localized: "Theme"),
            selection: self.$theme
        ) {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                Text(theme.localized).tag(theme)
            }
        }
    }
}

private struct LocalizationSettings: View {
    @AppLocale() var locale: Locale

    var body: some View {
        Picker(
            String(localized: "Measurements"),
            selection: self.$locale.units,
        ) {
            let systems = MeasurementSystem.measurementSystems
            ForEach(systems, id: \.self) { system in
                Text(system.localized).tag(system)
            }
        }

        Picker(
            String(localized: "First Weekday"),
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
    var body: some View { CalorieEditor(budget: self.budget) }
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
                CalorieEditor(budget: budget)
            }
        }
    }
}
