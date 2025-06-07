import SwiftData
import SwiftUI

// TODO: Animate changing theme

struct SettingsView: View {
    @Environment(\.modelContext)
    internal var context: ModelContext
    @Environment(\.colorScheme)
    internal var colorScheme: ColorScheme
    @Environment(\.healthKit)
    internal var healthKit: HealthKitService

    @AppStorage(.userGoals) var goalsID: UUID
    @AppStorage(.theme) var theme: AppTheme
    @AppLocale private var locale

    @State private var reset = false
    @State private var erase = false
    @State private var isErasing = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("General Settings")) {
                    generalSettings
                }

                GoalView(goalsID)

                Section {
                    HealthPermissionsManager(service: healthKit)
                } header: {
                    Text("Apple Health")
                } footer: {
                    Text(
                        """
                        Manage permissions for accessing health data at:
                        Settings > Privacy & Security > Health > \(AppName)
                        """
                    )
                }

                Section {
                    NavigationLink(
                        destination: AboutView()
                    ) {
                        Label("About", systemImage: "info.circle")
                    }
                }

                Section {
                    Button("Reset Settings", role: .destructive) {
                        reset = true
                    }
                    Button("Erase All Data", role: .destructive) {
                        erase = true
                    }
                }
            }
            .navigationTitle("Settings")
            .scrollDismissesKeyboard(.interactively)

            .resetAlert(isPresented: $reset)
            .eraseAlert(
                isPresented: $erase, isErasing: $isErasing,
                healthKit: healthKit, context: context
            )
        }
    }

    @ViewBuilder var generalSettings: some View {
        Picker(
            "Theme",
            systemImage: colorScheme == .light
                ? "sun.max.fill"
                : "moon.fill",
            selection: self.$theme,
            content: {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    if theme != .system {
                        Text(theme.localized).tag(theme)
                    }
                }

                Divider()
                Label {
                    Text("System")
                } icon: {
                    Image(systemName: "globe")
                }.tag(AppTheme.system)
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
                Divider()
                Label {
                    Text("System")
                } icon: {
                    Image(systemName: "globe")
                }.tag(nil as MeasurementSystem?)
            },
        ) {
            if self.$locale.units.wrappedValue == nil {
                Text("System")
            } else {
                Text(self.locale.measurementSystem.localized)
            }
        }
        .frame(maxHeight: 8)

        Picker(
            "First Weekday", systemImage: "calendar",
            selection: self.$locale.firstWeekDay,
            content: {
                ForEach(Weekday.allCases, id: \.self) { weekday in
                    Text(weekday.localized).tag(weekday)
                }
                Divider()
                Label {
                    Text("System")
                } icon: {
                    Image(systemName: "globe")
                }.tag(nil as MeasurementSystem?)
            }
        ) { Text(self.locale.firstDayOfWeek.abbreviated) }
        .frame(maxHeight: 8)
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
        isPresented: Binding<Bool>, isErasing: Binding<Bool>,
        healthKit: HealthKitService, context: ModelContext
    ) -> some View {
        self.alert("Erase All App Data", isPresented: isPresented) {
            Button("Cancel", role: .cancel) {}
            Button("Erase", role: .destructive) {
                withAnimation {
                    isPresented.wrappedValue = false
                    isErasing.wrappedValue = true
                }

                Task {
                    UserDefaults.standard.resetSettings()
                    try? context.container.erase()
                    try await healthKit.eraseData()
                    withAnimation {
                        isErasing.wrappedValue = false
                    }
                }
            }
        } message: {
            Text(
                """
                Erase all health data, settings, and app data.
                This action cannot be undone.
                """
            )
        }
        .overlay {
            if isErasing.wrappedValue {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView("Erasing Health Data...")
                        .progressViewStyle(.circular)
                        .padding()
                        .background(
                            .regularMaterial,
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                }
                .transition(.opacity)
            }
        }
    }
}

struct HealthPermissionsManager: View {
    let service: HealthKitService

    var body: some View {
        Button {
            service.requestAuthorization()
        } label: {
            Label {
                HStack {
                    Text("Permissions")
                        .foregroundStyle(Color.primary)
                    Spacer()
                    switch service.authorizationStatus() {
                    case .notReviewed:
                        Label {
                            Image(systemName: "lock.shield.fill")
                                .foregroundStyle(Color.accent)
                        } icon: {
                            Text("Request")
                                .foregroundStyle(Color.accent)
                        }
                    case .authorized:
                        Label {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundStyle(Color.green)
                        } icon: {
                            Text("Authorized")
                                .foregroundStyle(Color.secondary)
                        }
                    case .denied:
                        Label {
                            Image(systemName: "xmark.shield.fill")
                                .foregroundStyle(Color.red)
                        } icon: {
                            Text("Denied")
                                .foregroundStyle(Color.secondary)
                        }
                    case .partiallyAuthorized:
                        Label {
                            Image(systemName: "exclamationmark.shield.fill")
                                .foregroundStyle(Color.yellow)
                        } icon: {
                            Text("Partially Authorized")
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            } icon: {
                Image.healthKit
                    .foregroundStyle(Color.healthKit)
            }
        }
    }
}
