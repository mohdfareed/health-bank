import SwiftData
import SwiftUI

// TODO: Add dashboard view to track goals and progress

struct AppView: View {
    @AppStorage(.theme)
    internal var theme: AppTheme
    // @AppLocale private var locale

    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "square.grid.2x2") { Group {} }
            Tab("Records", systemImage: "list.clipboard") { HealthDataView() }
            Tab("Settings", systemImage: "gear") { SettingsView() }
        }
        // .environment(\.locale, self.locale)
        .preferredColorScheme(self.theme.colorScheme)
    }
}
