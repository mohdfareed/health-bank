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

#Preview {
    SettingsView().modelContainer(
        for: [UserGoals.self], inMemory: true
    )
}
