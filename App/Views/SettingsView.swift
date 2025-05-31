import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage(.userGoals) var goalsID: UUID
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

private struct GoalSettings: View {
    @Environment(\.modelContext) private var context: ModelContext
    @Query.Singleton var goals: UserGoals
    init(_ id: UUID) {
        self._goals = .init(id)
    }

    var body: some View {
        let macros = $goals.macros.defaulted(to: .init())
        VStack {
            Section(header: Text(String(localized: "Daily Calorie Budget"))) {
                MeasurementRow.dietaryCalorie(
                    measurement: .calorie($goals.calories),
                    title: "Calories", source: .local,
                    computed: goals.calorieGoal.calculatedCalories
                )
                MeasurementRow.protein(
                    measurement: .macro(macros.protein),
                    source: .local,
                    computed: goals.calorieGoal.calculatedProtein
                )
                MeasurementRow.carbs(
                    measurement: .macro(macros.carbs),
                    source: .local,
                    computed: goals.calorieGoal.calculatedCarbs
                )
                MeasurementRow.fat(
                    measurement: .macro(macros.fat),
                    source: .local,
                    computed: goals.calorieGoal.calculatedFat
                )
            }

            Section(header: Text(String(localized: "Daily Activity Goals"))) {
                MeasurementRow.calorie(
                    measurement: .calorie($goals.burnedCalories),
                    source: .local,
                )
                MeasurementRow.activity(
                    measurement: .activity($goals.activity),
                    source: .local
                )
            }

            Section(header: Text(String(localized: "Target Measurements"))) {
                MeasurementRow.weight(
                    measurement: .weight($goals.weight),
                    source: .local, showPicker: true
                )
            }
        }
        .onChange(of: goals) { save() }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            AppLogger.new(for: GoalSettings.self)
                .error("Failed to save model: \(error)")
        }
    }
}

#Preview {
    SettingsView().modelContainer(
        for: [UserGoals.self], inMemory: true
    )
}
