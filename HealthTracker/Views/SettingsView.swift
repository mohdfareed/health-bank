import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage(.dailyCalorieBudget)
    var calorieBudget: CalorieBudget.ID

    init() {
        print("Loading settings...")

    }

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
                Text(theme.identifier).tag(theme)
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
    @AppStorage(.unitSystem)
    var units: MeasurementSystem?
    @AppStorage(.firstDayOfWeek)
    var firstWeekDay: Weekday?

    var body: some View {
        Picker(
            String(localized: "Measurement"),
            selection: self.$units.defaulted(
                to: Locale.autoupdatingCurrent.measurementSystem
            )
        ) {
            let systems = MeasurementSystem.measurementSystems
            ForEach(systems, id: \.self) { system in
                Text(system.identifier).tag(system)
            }
        }
        Picker(
            String(localized: "First Weekday"),
            selection: self.$firstWeekDay
        ) {
            ForEach(Weekday.allCases, id: \.self) { weekday in
                Text(weekday.abbreviated).tag(weekday)
            }
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
