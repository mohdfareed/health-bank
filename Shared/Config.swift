import SwiftData
import SwiftUI

// TODO: Create reusable goals the user can choose from.
// TODO: Create calorie entries preset system.

/// The app's name.
public let AppName = String(localized: "HealthVaults")
/// The app's bundle identifier.
public let AppID = "com.MohdFareed.HealthVaults"

// Widget IDs - Each widget type needs a unique identifier
public let BudgetWidgetID = "\(AppID).BudgetWidget"
public let MacrosWidgetID = "\(AppID).MacrosWidget"

/// The widgets bundle identifier (legacy - for compatibility).
public let WidgetsID = "\(AppID).Widgets"
/// The HealthKit observers bundle identifier.
public let ObserversID = "\(AppID).Observers"
/// The App Groups identifier for sharing data between app and widgets.
public let AppGroupID = "group.\(AppID).shared"
/// The source code repository URL.
public let RepoURL = "https://github.com/mohdfareed/health-vaults"

// MARK: Shared Schema
// ============================================================================

/// The app's schema for SwiftData.
public enum AppSchema {
    @MainActor public static let schema = Schema([UserGoals.self])

    /// Creates a ModelContainer configured for App Groups sharing.
    @MainActor public static func createContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(AppGroupID)
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
