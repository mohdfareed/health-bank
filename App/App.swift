import BackgroundTasks
import HealthVaultsShared
import SwiftData
import SwiftUI
import WidgetKit

@main struct MainApp: App {
    internal let logger = AppLogger.new(for: Self.self)
    let container: ModelContainer

    init() {
        // MARK: Model Container Initialization
        // ====================================================================
        do {
            self.logger.debug("Initializing model container for \(AppID)")
            self.container = try AppSchema.createContainer()
        } catch {
            #if !DEBUG  // Production migration logic
                fatalError("Failed to initialize model container: \(error)")
            #endif  // Debug migration logic
            self.logger.error("Failed to initialize model container: \(error)")

            do {  // Attempt to replace existing container
                self.logger.warning("Replacing existing model container...")
                try ModelContainer().erase()
                self.container = try AppSchema.createContainer()
            } catch {
                self.logger.error(
                    "Failed to initialize replacement container: \(error)"
                )

                // Fallback to in-memory container
                logger.warning("Falling back to in-memory container.")
                self.container = try! .init(
                    for: AppSchema.schema,
                    configurations: .init(isStoredInMemoryOnly: true)
                )
            }
        }

        // MARK: HealthKit Observer Setup
        // ====================================================================
        AppHealthKitObserver.shared.startObserving()
        self.logger.debug("Started HealthKit observer for widget updates")

        // MARK: Background Task Setup
        // ====================================================================
        #if os(iOS)
            registerBackgroundTasks()
            scheduleBackgroundRefresh()
            self.logger.debug("Registered background tasks for widget refresh")
        #endif
    }

    // MARK: Background Tasks
    // ========================================================================

    #if os(iOS)
        private func registerBackgroundTasks() {
            BGTaskScheduler.shared.register(
                forTaskWithIdentifier: "com.MohdFareed.HealthVaults.widget-refresh",
                using: nil
            ) { task in
                self.handleWidgetRefresh(task: task as! BGAppRefreshTask)
            }
        }

        private func scheduleBackgroundRefresh() {
            let request = BGAppRefreshTaskRequest(
                identifier: "com.MohdFareed.HealthVaults.widget-refresh")
            request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)  // 15 minutes

            try? BGTaskScheduler.shared.submit(request)
        }

        private func handleWidgetRefresh(task: BGAppRefreshTask) {
            // Schedule the next refresh
            scheduleBackgroundRefresh()

            task.expirationHandler = {
                task.setTaskCompleted(success: false)
            }

            // Refresh all widgets
            WidgetCenter.shared.reloadAllTimelines()
            task.setTaskCompleted(success: true)
        }
    #endif

    // MARK: App Setup
    // ========================================================================
    var body: some Scene {
        WindowGroup {
            AppView()
                .modelContainer(self.container)
                .onAppear {
                    AppHealthKitObserver.shared.startObserving()
                }
        }
    }
}

#Preview {
    AppView()
        .modelContainer(
            try! ModelContainer(
                for: AppSchema.schema,
                configurations: .init(isStoredInMemoryOnly: true)
            )
        )
}
