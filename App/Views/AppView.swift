import SwiftData
import SwiftUI

// TODO: Add dashboard view to track goals and progress

struct AppView: View {
    @AppStorage(.theme)
    internal var theme: AppTheme
    // @AppLocale private var locale

    var body: some View {
        TabView {
            Tab(
                String(localized: "Dashboard"), systemImage: "square.grid.2x2"
            ) { Group {} }
            Tab(
                String(localized: "Records"), systemImage: "list.clipboard"
            ) { HealthDataView() }
            Tab(
                String(localized: "Settings"), systemImage: "gear"
            ) { SettingsView() }
        }
        // .environment(\.locale, self.locale)
        .preferredColorScheme(self.theme.colorScheme)
    }
}

#Preview {
    AppView()
}
