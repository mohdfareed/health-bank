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
                    String(localized: "Reset Settings"),
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

    var body: some View {
        MeasurementField(
            text: String(localized: "Calories"),
            image: AppIcons.dietaryCalorie, fractions: 0,
            measurement: .init(
                self.$budget.calories.optional(0), definition: .calorie
            )
        )
        MeasurementField(
            text: String(localized: "Protein"),
            image: AppIcons.protein, fractions: 0,
            measurement: .init(
                self.$budget.macros.protein, definition: .macro
            )
        )
        MeasurementField(
            text: String(localized: "Fat"),
            image: AppIcons.fat, fractions: 0,
            measurement: .init(
                self.$budget.macros.fat, definition: .macro
            )
        )
        MeasurementField(
            text: String(localized: "Carbs"),
            image: AppIcons.carbs, fractions: 0,
            measurement: .init(
                self.$budget.macros.carbs, definition: .macro
            )
        )
    }
}
