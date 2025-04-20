import SwiftData
import SwiftUI

/// The app's bundle identifier.
let appID: String = Bundle.main.bundleIdentifier ?? "Debug.HealthTracker"

@main struct HealthTrackerApp: App {
    internal let logger = AppLogger.new(for: Self.self)

    fileprivate let localContainer: ModelContainer
    fileprivate let remoteContext: RemoteContext
    fileprivate let unitService: UnitService

    private let localModels: [any PersistentModel.Type] = [
        CoreDietaryCalorie.self,
        CoreRestingCalorie.self,
        CoreWorkout.self,
        CalorieBudget.self,  // FIXME: breaks the app
    ]

    init() {
        self.remoteContext = RemoteContext(
            stores: []
        )
        self.localContainer = try! ModelContainer(
            for: Schema(self.localModels),
            configurations: ModelConfiguration()
        )
        self.unitService = UnitService(providers: [:])
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .modelContainer(self.localContainer)
                .remoteContext(self.remoteContext)
                .unitService(self.unitService)
        }
    }
}

struct AppView: View {
    @AppStorage(.theme)
    internal var theme: AppTheme
    @AppLocale()
    internal var locale: Locale

    init(reset: Bool = false) {
        if reset { UserDefaults.standard.resetSettings() }
    }

    var body: some View {
        TabView {
            Tab(String(localized: "Dashboard"), systemImage: "square.grid.2x2") {
                SettingsView()
            }
            Tab(String(localized: "Data"), systemImage: "list.clipboard") {
                SettingsView()
            }
            Tab(String(localized: "Settings"), systemImage: "gear") {
                SettingsView()
            }
        }
        .environment(\.locale, self.locale)
        .preferredColorScheme(self.theme.colorScheme)
    }
}

#Preview {
    let app = HealthTrackerApp()
    AppView(reset: true)
        .modelContainer(app.localContainer)
        .remoteContext(app.remoteContext)
        .unitService(app.unitService)
}
