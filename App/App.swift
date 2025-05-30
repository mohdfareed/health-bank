import SwiftData
import SwiftUI

/// The app's bundle identifier.
let appID: String = Bundle.main.bundleIdentifier ?? "Debug.App"

@main struct MainApp: App {
    internal let logger = AppLogger.new(for: Self.self)
    let localContainer: ModelContainer

    init() {
        self.localContainer = try! ModelContainer(
            for: Schema([
                UserGoals.self,
                DietaryCalorie.self,
                ActiveEnergy.self,
                RestingEnergy.self,
                Weight.self,
            ]),
            configurations: ModelConfiguration(isStoredInMemoryOnly: true),
        )
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .modelContainer(self.localContainer)
                .appLocale()
        }
    }
}

#Preview {
    AppView().modelContainer(MainApp().localContainer)
}
