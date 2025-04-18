import SwiftData
import SwiftUI

/// The app's bundle identifier.
let appID: String = Bundle.main.bundleIdentifier ?? "Debug.HealthTracker"

@main struct HealthTrackerApp: App {
    internal let logger = AppLogger.new(for: Self.self)
    private let models: [any PersistentModel.Type] = [
        CalorieBudget.self,
        ConsumedCalorie.self,
        BurnedCalorie.self,
    ]

    @AppStorage(AppSettings.theme)
    internal var theme: AppTheme
    internal var localContainer: ModelContainer
    internal var remoteContext: RemoteContext
    internal var unitService: UnitService

    init() {
        self.localContainer = try! ModelContainer(
            for: Schema(self.models),
            configurations: ModelConfiguration()
        )
        self.remoteContext = RemoteContext(
            stores: [

            ]
        )
        self.unitService = UnitService(providers: [:])
    }

    var body: some Scene {
        WindowGroup {
            SettingsView().setup(app: self)
        }
    }
}

extension View {
    /// Sets up the app environment for the view.
    func setup(app: HealthTrackerApp) -> some View {
        self
            .modelContainer(app.localContainer)
            .remoteContext(app.remoteContext)
            .unitService(app.unitService)
            .preferredColorScheme(app.theme.colorScheme)
    }
}

#Preview {
    SettingsView().setup(app: .init())
        .remoteContext(.init(stores: [SimulatedStore(for: [])]))
}
