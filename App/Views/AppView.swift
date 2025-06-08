import SwiftData
import SwiftUI

// TODO: Add dashboard view to track goals and progress
// TODO: Add welcome screen for new users

struct AppView: View {
    @AppStorage(.theme)
    internal var theme: AppTheme
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme
    @AppLocale private var locale

    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "square.grid.2x2") {
                Group {}
            }
            Tab("Data", systemImage: "heart.text.clipboard.fill") {
                HealthDataView()
            }
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
        }
        .environment(\.locale, self.locale)
        .preferredColorScheme(self.theme.colorScheme)

        .animation(.default, value: self.theme)
        .animation(.default, value: self.colorScheme)
        .animation(.default, value: self.locale)

        .contentTransition(.symbolEffect(.replace))
        .contentTransition(.numericText())
        .contentTransition(.opacity)
    }
}
