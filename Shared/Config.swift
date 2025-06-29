import SwiftData
import SwiftUI

// TODO: Create reusable goals the user can choose from.
// TODO: Create calorie entries preset system.

// MARK: - App Configuration
// ============================================================================

/// App name for display purposes.
public let AppName = String(localized: "HealthVaults")
/// App bundle identifier for entitlements and configuration.
public let AppID = "com.MohdFareed.HealthVaults"

/// Budget widget identifier for WidgetKit.
public let BudgetWidgetID = "\(AppID).BudgetWidget"
/// Macros widget identifier for WidgetKit.
public let MacrosWidgetID = "\(AppID).MacrosWidget"

/// Legacy widgets bundle identifier (compatibility).
public let WidgetsID = "\(AppID).Widgets"
/// HealthKit observers dispatch queue identifier.
public let ObserversID = "\(AppID).Observers"
/// App Groups container for shared data between app and widgets.
public let AppGroupID = "group.\(AppID).shared"
/// Source repository URL.
public let RepoURL = "https://github.com/mohdfareed/health-vaults"

// MARK: - SwiftData Schema
// ============================================================================

/// App's SwiftData schema with App Groups support.
public enum AppSchema {
    @MainActor public static let schema = Schema([UserGoals.self])

    /// Creates ModelContainer configured for App Groups data sharing.
    @MainActor public static func createContainer() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(AppGroupID)
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
