import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage(.dailyCalorieBudget) var budgetID: UUID
    @State private var reset = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(String(localized: "General Settings"))) {
                    GeneralSettings()
                    LocalizationSettings()
                }

                Button(
                    String(localized: "Reset All Settings"),
                    role: .destructive
                ) { reset = true }
            }
            .navigationTitle(String(localized: "Settings"))

            .alert(String(localized: "Confirm Reset"), isPresented: $reset) {
                Button(String(localized: "Reset"), role: .destructive) {
                    UserDefaults.standard.resetSettings()
                }
                Button(String(localized: "Cancel"), role: .cancel) {}
            } message: {
                Text(
                    String(
                        localized: """
                            Are you sure you want to reset all settings?
                            This action cannot be undone.
                            """
                    )
                )
            }
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

#Preview {
    SettingsView().modelContainer(for: CalorieBudget.self)
}
