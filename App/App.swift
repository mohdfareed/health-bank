import SwiftData
import SwiftUI

/// The app's bundle identifier.
let appID: String = Bundle.main.bundleIdentifier ?? "Debug.App"

@main struct MainApp: App {
    internal let logger = AppLogger.new(for: Self.self)
    let container: ModelContainer

    let schema = Schema([
        UserGoals.self,
        DietaryCalorie.self,
        ActiveEnergy.self,
        RestingEnergy.self,
        Weight.self,
    ])

    init() {
        self.container = try! .init(
            for: schema, configurations: .init(),
        )
    }

    var body: some Scene {
        WindowGroup {
            AppView()
                .modelContainer(self.container)
                .healthKit(.init())
                .appLocale()
        }
    }
}

#Preview {
    AppView().modelContainer(
        try! .init(
            for: MainApp().schema,
            configurations: .init(isStoredInMemoryOnly: true)
        )
    )
}
