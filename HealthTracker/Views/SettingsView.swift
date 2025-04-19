import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage(.dailyCalorieBudget)
    var calorieBudget: CalorieBudget.ID

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(String(localized: "Daily Calorie Budget"))) {
                    CalorieBudgetEditor(budget: .init(self.calorieBudget))
                }

                Section(header: Text(String(localized: "General Settings"))) {
                    GeneralSettings()
                }

                Section(header: Text(String(localized: "Localization"))) {
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

        Toggle(
            String(localized: "Enable Biometrics"),
            isOn: self.$biometrics.defaulted(to: false)
        )

        Toggle(
            String(localized: "Enable Notifications"),
            isOn: self.$notifications.defaulted(to: false)
        )
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

struct CalorieBudgetEditor: View {
    @Query.Singleton var budget: CalorieBudget

    let budgetError = Text(String(localized: "Budget must be greater than 0"))
        .foregroundStyle(.red)

    var body: some View {
        // MeasurementField(
        //     text: String(localized: "Calories"),
        //     image: AppIcons.dietaryCalorie, color: .orange, fractions: 0,
        //     validator: {
        //         guard $0 ?? 0 < 0 else {
        //             return Text(String(localized: "Daily calories"))
        //         }
        //         return self.budgetError
        //     },
        //     measurement: .init(
        //         self.$budget.calories.optional(0), definition: .calorie
        //     ),
        //     computed: self.budget.calculatedCalories()
        // )

        // MeasurementField(
        //     text: String(localized: "Protein"),
        //     image: AppIcons.protein, color: .green, fractions: 0,
        //     validator: {
        //         guard $0 ?? 0 < 0 else {
        //             return Text(String(localized: "Daily proteins"))
        //         }
        //         return self.budgetError
        //     },
        //     measurement: .init(
        //         self.$budget.macros.defaulted(to: .init()).protein,
        //         definition: .macro
        //     ),
        //     computed: self.budget.calculatedProtein()
        // )

        // MeasurementField(
        //     text: String(localized: "Carbs"),
        //     image: AppIcons.carbs, color: .purple, fractions: 0,
        //     validator: {
        //         guard $0 ?? 0 < 0 else {
        //             return Text(String(localized: "Daily carbohydrates"))
        //         }
        //         return self.budgetError
        //     },
        //     measurement: .init(
        //         self.$budget.macros.defaulted(to: .init()).carbs,
        //         definition: .macro
        //     ),
        //     computed: self.budget.calculatedFat()
        // )

        // MeasurementField(
        //     text: String(localized: "Fat"),
        //     image: AppIcons.fat, color: .yellow, fractions: 0,
        //     validator: {
        //         guard $0 ?? 0 < 0 else {
        //             return Text(String(localized: "Daily fats"))
        //         }
        //         return self.budgetError
        //     },
        //     measurement: .init(
        //         self.$budget.macros.defaulted(to: .init()).fat,
        //         definition: .macro
        //     ),
        //     computed: self.budget.calculatedFat()
        // )
    }
}
