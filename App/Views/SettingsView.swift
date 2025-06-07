import SwiftData
import SwiftUI

// TODO: Add licenses subpage with Apple Health licenses
// TODO: Animate changing theme

struct SettingsView: View {
    @Environment(\.modelContext)
    internal var context: ModelContext
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    @AppStorage(.userGoals) var goalsID: UUID
    @AppStorage(.theme) var theme: AppTheme
    @AppLocale private var locale

    @State private var reset = false
    @State private var erase = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("General Settings")) {
                    Picker(
                        "Theme",
                        systemImage: colorScheme == .light
                            ? "sun.max.fill"
                            : "moon.fill",
                        selection: self.$theme,
                        content: {
                            ForEach(AppTheme.allCases, id: \.self) { theme in
                                Text(theme.localized).tag(theme)
                            }
                        }
                    ) { Text(self.theme.localized) }
                    .frame(maxHeight: 8)

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

                GoalView(goalsID)

                Button(
                    "Reset Settings",
                    role: .destructive
                ) { reset = true }

                Button(
                    "Erase All Data",
                    role: .destructive
                ) { erase = true }
            }
            .navigationTitle("Settings")
            .scrollDismissesKeyboard(.immediately)

            .resetAlert(isPresented: $reset)
            .eraseAlert(isPresented: $erase, context: context)
        }
    }
}

extension View {
    fileprivate func resetAlert(isPresented: Binding<Bool>) -> some View {
        self.alert("Reset All Settings", isPresented: isPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                UserDefaults.standard.resetSettings()
            }
        } message: {
            Text(
                """
                Reset all settings to their default values.
                This action cannot be undone.
                """
            )
        }
    }

    fileprivate func eraseAlert(
        isPresented: Binding<Bool>, context: ModelContext
    ) -> some View {
        self.alert("Erase All App Data", isPresented: isPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Erase", role: .destructive) {
                UserDefaults.standard.resetSettings()
                context.eraseAll()
            }
        } message: {
            Text(
                """
                Erase all health records, settings, and app data.
                This action cannot be undone.
                """
            )
        }
    }
}
