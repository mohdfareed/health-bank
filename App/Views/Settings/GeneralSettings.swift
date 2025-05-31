import SwiftUI

struct GeneralSettings: View {
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
        ) { Text(self.theme.localized) }
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

        LocalizationSettings()
    }
}

private struct LocalizationSettings: View {
    @AppLocale private var locale

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
            Text(self.locale.measurementSystem.localized)
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
            Text(self.locale.firstDayOfWeek.abbreviated)
        }
    }
}
