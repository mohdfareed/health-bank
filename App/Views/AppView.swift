import SwiftData
import SwiftUI

// TODO: Add entries tab that shows all entries, filterable by type and source
// TODO: Add dashboard view to track goals and progress

struct AppView: View {
    @AppStorage(.theme)
    internal var theme: AppTheme
    // @AppLocale private var locale

    var body: some View {
        TabView {
            Tab(
                String(localized: "Dashboard"),
                systemImage: "square.grid.2x2"
            ) { DemoView(title: "Dashboard") }
            Tab(
                String(localized: "Data"), systemImage: "list.clipboard"
            ) { DemoView(title: "Data") }
            Tab(
                String(localized: "Settings"), systemImage: "gear"
            ) { SettingsView() }
        }
        // .environment(\.locale, self.locale)
        .preferredColorScheme(self.theme.colorScheme)
    }
}

struct DemoView: View {
    var title: String
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

                Text(title)
                    .font(.title2)

                Divider()
                    .padding(.vertical)

                Text("Work in Progress")
                    .font(.headline)
            }
            .padding()
            .navigationTitle(AppName)
        }
    }
}

#Preview {
    AppView()
}
