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
        // MARK: Model Container Initialization
        // ====================================================================
        do {
            self.logger.debug("Initializing model container for \(appID)")
            self.container = try .init(for: schema)
        } catch {
            #if !DEBUG  // Production migration logic
                fatalError("Failed to initialize model container: \(error)")
            #endif  // Debug migration logic
            self.logger.error("Failed to initialize model container: \(error)")

            do {  // Attempt to replace existing container
                self.logger.warning("Replacing existing model container...")
                try ModelContainer().erase()
                self.container = try .init(for: schema)
            } catch {
                self.logger.error(
                    "Failed to initialize replacement container: \(error)"
                )

                // Fallback to in-memory container
                logger.warning("Falling back to in-memory container.")
                self.container = try! .init(
                    for: schema,
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
                .appLocale()
        }
    }
}

// MARK: Preview
// ============================================================================

#Preview {
    let container = try! ModelContainer(
        for: MainApp().schema,
        configurations: .init(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext

    // Weight entries
    let weightLocal = Weight(
        72.5, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        source: .local,
    )
    let weightHealthKit = Weight(
        73.0, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        source: .healthKit
    )
    context.insert(weightLocal)
    context.insert(weightHealthKit)

    // Dietary Calorie entries
    let dietaryLocal = DietaryCalorie(
        650, date: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
        source: .local, macros: CalorieMacros(p: 35, f: 20, c: 75)
    )
    let dietaryHealthKit = DietaryCalorie(
        420, date: Calendar.current.date(byAdding: .hour, value: -5, to: Date())!,
        source: .healthKit, macros: CalorieMacros(p: 25, f: 15, c: 50)
    )
    context.insert(dietaryLocal)
    context.insert(dietaryHealthKit)

    // Active Energy entries
    let activeLocal = ActiveEnergy(
        280, date: Calendar.current.date(byAdding: .hour, value: -1, to: Date())!,
        source: .local, duration: 88, workout: .weightlifting
    )  // 40 min run
    let activeHealthKit = ActiveEnergy(
        180, date: Calendar.current.date(byAdding: .hour, value: -4, to: Date())!,
        source: .healthKit, duration: 35, workout: .cycling
    )  // 30 min walk
    context.insert(activeLocal)
    context.insert(activeHealthKit)

    // Resting Energy entries
    let restingLocal = RestingEnergy(
        1850, date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
        source: .local
    )
    let restingHealthKit = RestingEnergy(
        1820, date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
        source: .healthKit
    )
    context.insert(restingLocal)
    context.insert(restingHealthKit)

    try! context.save()
    return AppView()
        .modelContainer(container)
        .colorScheme(.dark)
}
