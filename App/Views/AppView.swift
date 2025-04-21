import SwiftData
import SwiftUI

struct AppView: View {
    @AppStorage(.theme)
    internal var theme: AppTheme
    @AppLocale()
    internal var locale: Locale

    var body: some View {
        TabView {
            Tab(
                String(localized: "Dashboard"),
                systemImage: "square.grid.2x2"
            ) { SettingsView() }
            Tab(
                String(localized: "Data"), systemImage: "list.clipboard"
            ) { SettingsView() }
            Tab(
                String(localized: "Settings"), systemImage: "gear"
            ) { SettingsView() }
        }
        .environment(\.locale, self.locale)
        .preferredColorScheme(self.theme.colorScheme)
    }
}

#Preview {
    AppView()
}
