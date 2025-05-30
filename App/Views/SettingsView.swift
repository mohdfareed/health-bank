import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage(.dailyGoals) var goalsID: UUID
    @State private var reset = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(String(localized: "General Settings"))) {
                    GeneralSettings()
                    LocalizationSettings()
                }

                GoalSettings(goalsID)

                Button(
                    String(localized: "Reset All Settings"),
                    role: .destructive
                ) { reset = true }
            }
            .navigationTitle(String(localized: "Settings"))
            .resetAlert(isPresented: $reset)
        }
        .refreshable {
            self.reset = false
        }
    }
}

extension View {
    fileprivate func resetAlert(isPresented: Binding<Bool>) -> some View {
        self.alert(
            String(localized: "Confirm Reset"), isPresented: isPresented
        ) {
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
            ).labelsHidden()
        }
    }
}

private struct GoalSettings: View {
    @Query.Singleton var goals: Goals
    init(_ id: UUID) {
        self._goals = .init(id)
    }

    var body: some View {
        Section(header: Text(String(localized: "Calorie Budget"))) {
            CaloriesRow(calorie: $goals.calorieGoal.casted(), showDate: false)
            MacrosProteinRow(calorie: $goals.calorieGoal.casted(), showDate: false)
            MacrosCarbsRow(calorie: $goals.calorieGoal.casted(), showDate: false)
            MacrosFatRow(calorie: $goals.calorieGoal.casted(), showDate: false)
        }
        Section(header: Text(String(localized: "Activity Goals"))) {
            BurnedCaloriesRow(calorie: $goals.activityGoal.casted(), showDate: false)
            ActivityRow(calorie: $goals.activityGoal.casted(), showDate: false)
        }
        Section(header: Text(String(localized: "Target Measurements"))) {
            WeightRow(weight: $goals.weightGoal.casted(), showDate: false)
        }
    }
}

#Preview {
    SettingsView().modelContainer(
        for: [Goals.self], inMemory: true
    )
}
