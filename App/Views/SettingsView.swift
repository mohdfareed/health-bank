import SwiftData
import SwiftUI

// TODO: Add licenses subpage with Apple Health licenses

struct SettingsView: View {
    @Environment(\.modelContext)
    internal var context: ModelContext

    @AppStorage(.userGoals) var goalsID: UUID
    @State private var reset = false
    @State private var erase = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("General Settings")) {
                    GeneralSettings()
                    LocalizationSettings()
                    if HealthKitService.isAvailable {
                        HealthKitSettings()
                    }
                }

                GoalView(goalsID)

                Button(
                    "Reset Settings",
                    role: .destructive
                ) { reset = true }

                Button(
                    "Erase Data",
                    role: .destructive
                ) { erase = true }
            }
            .navigationTitle("Settings")
            .scrollDismissesKeyboard(.interactively)
            .resetAlert(isPresented: $reset)
            .eraseAlert(isPresented: $erase, context: context)
        }
    }
}

extension View {
    fileprivate func resetAlert(isPresented: Binding<Bool>) -> some View {
        self.alert(
            "Reset All Settings", isPresented: isPresented
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                UserDefaults.standard.resetSettings()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    fileprivate func eraseAlert(
        isPresented: Binding<Bool>, context: ModelContext
    ) -> some View {
        self.alert(
            "Erase All Data", isPresented: isPresented
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Erase", role: .destructive) {
                UserDefaults.standard.resetSettings()
                context.eraseAll()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

struct GeneralSettings: View {
    @AppStorage(.theme) var theme: AppTheme
    @AppStorage(.notifications) var notifications: Bool?
    @AppStorage(.biometrics) var biometrics: Bool?

    var body: some View {
        Picker(
            "Theme", systemImage: "paintbrush",
            selection: self.$theme,
            content: {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Text(theme.localized).tag(theme)
                }
            }
        ) { Text(self.theme.localized) }
        .frame(maxHeight: 8)

        // TODO: Implement notifications and biometrics settings
        // Toggle(isOn: self.$notifications.defaulted(to: false)) {
        //     Label(
        //         "Enable notifications",
        //         systemImage: "bell"
        //     ).labelStyle(.automatic)
        // }

        // Toggle(isOn: self.$biometrics.defaulted(to: false)) {
        //     Label(
        //         "Enable biometrics",
        //         systemImage: "faceid"
        //     ).labelStyle(.automatic)
        // }
    }
}

private struct LocalizationSettings: View {
    @AppLocale private var locale

    var body: some View {
        Picker(
            "Measurements", systemImage: "ruler",
            selection: self.$locale.units,
            content: {
                let systems = MeasurementSystem.measurementSystems
                ForEach(systems, id: \.self) { system in
                    Text(system.localized).tag(system)
                }
            },
        ) { Text(self.locale.measurementSystem.localized) }
        .frame(maxHeight: 8)

        Picker(
            "First Weekday", systemImage: "calendar",
            selection: self.$locale.firstWeekDay,
            content: {
                ForEach(Weekday.allCases, id: \.self) { weekday in
                    Text(weekday.localized).tag(weekday)
                }
            }
        ) { Text(self.locale.firstDayOfWeek.abbreviated) }
        .frame(maxHeight: 8)
    }
}

private struct HealthKitSettings: View {
    @Environment(\.healthKit)
    private var healthKitService

    @AppStorage(.enableHealthKit)
    private var enableHealthKit: Bool

    var body: some View {
        Toggle(isOn: self.$enableHealthKit) {
            Label {
                Text("Apple Health Integration")
            } icon: {
                Image.healthKit
            }
        }
        .onChange(of: self.enableHealthKit) { _, newValue in
            if newValue {
                healthKitService.requestAuthorization()
            }
        }
    }
}
