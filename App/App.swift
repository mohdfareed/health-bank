import SwiftData
import SwiftUI

/// The app's bundle identifier.
let AppID: String = Bundle.main.bundleIdentifier ?? "Debug.App"
/// The source code repository URL.
let RepoURL: String = "https://github.com/mohdfareed/health-bank"

@main struct MainApp: App {
    internal let logger = AppLogger.new(for: Self.self)
    let container: ModelContainer

    static var schema: Schema {
        .init([
            UserGoals.self
        ])
    }

    init() {
        // MARK: Model Container Initialization
        // ====================================================================
        do {
            self.logger.debug("Initializing model container for \(AppID)")
            self.container = try .init(for: MainApp.schema)
        } catch {
            #if !DEBUG  // Production migration logic
                fatalError("Failed to initialize model container: \(error)")
            #endif  // Debug migration logic
            self.logger.error("Failed to initialize model container: \(error)")

            do {  // Attempt to replace existing container
                self.logger.warning("Replacing existing model container...")
                try ModelContainer().erase()
                self.container = try .init(for: MainApp.schema)
            } catch {
                self.logger.error(
                    "Failed to initialize replacement container: \(error)"
                )

                // Fallback to in-memory container
                logger.warning("Falling back to in-memory container.")
                self.container = try! .init(
                    for: MainApp.schema,
                    configurations: .init(isStoredInMemoryOnly: true)
                )
            }
        }
    }

    // MARK: App Setup
    // ========================================================================
    var body: some Scene {
        WindowGroup {
            AppView()
                .modelContainer(self.container)
                .healthKit(.init())
        }
    }
}

#Preview {
    // TODO: use mock health kit service
    AppView()
}
