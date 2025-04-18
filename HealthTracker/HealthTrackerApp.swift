import SwiftData
import SwiftUI

/// The app's bundle identifier.
let appID: String = Bundle.main.bundleIdentifier ?? "Debug.HealthTracker"

@main struct HealthTrackerApp: App {
    @AppStorage(.theme)
    internal var theme: AppTheme
    internal let logger = AppLogger.new(for: Self.self)

    private let models: [any PersistentModel.Type] = [
        CoreDietaryCalorie.self,
        CoreRestingCalorie.self,
        CoreWorkout.self,
    ]

    /// Sets up the app environment for the view.
    func setup(_ view: some View) -> some View {
        let simulatedModels: [any PersistentModel] = [
            CoreDietaryCalorie(
                100, macros: .init(protein: 10, fat: 5, carbs: 15),
                on: Date().adding(-1, .day), from: .simulation
            )
        ]

        let remoteContext = RemoteContext(
            stores: [
                SimulatedStore(for: simulatedModels)
            ]
        )
        let localContainer = try! ModelContainer(
            for: Schema(self.models),
            configurations: ModelConfiguration()
        )
        let unitService = UnitService(providers: [:])

        return withAnimation(.spring) {
            view
                .remoteContext(remoteContext)
                .modelContainer(localContainer)
                .unitService(unitService)
                .preferredColorScheme(self.theme.colorScheme)
                .animation(.default, value: self.theme)
        }
    }

    var body: some Scene {
        WindowGroup {
            VStack {
                SettingsView().setup(app: self)
                    .animation(.spring(), value: self.theme)
            }.animation(.spring(), value: self.theme)
        }
    }
}

extension View {
    /// Sets up the app environment for the view.
    func setup(app: HealthTrackerApp) -> some View { app.setup(self) }
}

#if DEBUG
    struct AppPreview: View {
        @AppStorage(.theme)
        internal var theme: AppTheme
        var body: some View {
            SettingsView().setup(app: .init())
                .remoteContext(.init(stores: [SimulatedStore(for: [])]))
                .preferredColorScheme(self.theme.colorScheme)
                .animation(.default, value: self.theme)
        }
    }
#endif
#Preview { AppPreview() }
