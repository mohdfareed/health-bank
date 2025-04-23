import SwiftData
import SwiftUI

/// The app's bundle identifier.
let appID: String = Bundle.main.bundleIdentifier ?? "Debug.App"

@main struct MainApp: App {
    internal let logger = AppLogger.new(for: Self.self)
    let localContainer: ModelContainer
    let remoteContext: RemoteContext
    let unitService: UnitService

    init() {
        self.localContainer = try! ModelContainer(
            for: Schema([
                CoreDietaryCalorie.self,
                CoreRestingCalorie.self,
                CoreWorkout.self,
                CalorieBudget.self,  // FIXME: breaks the app
            ]),
            configurations: ModelConfiguration()
        )
        self.remoteContext = RemoteContext(
            stores: []
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
