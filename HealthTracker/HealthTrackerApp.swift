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
            AppView.setup(app: self)
        }
    }
}

struct AppView: View {
    @AppStorage(.theme)
    internal var theme: AppTheme

    var body: some View {
        SettingsView().preferredColorScheme(self.theme.colorScheme)
    }

    static func setup(app: HealthTrackerApp) -> some View {
        return Self()
            .modelContainer(app.localContainer)
            .remoteContext(app.remoteContext)
            .unitService(app.unitService)
    }
}

#Preview { AppView.setup(app: .init()) }
