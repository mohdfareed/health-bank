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
            ) { DemoView() }
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

struct DemoView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image.logo
                    .foregroundStyle(.logoGradient)
                    .imageScale(.large)
                    .font(.system(size: 60))

                Text(AppName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding()
            .navigationTitle(AppName)
        }
    }
}

#Preview {
    AppView()
}
