import SwiftUI

// TODO: Create reusable goals the user can choose from.
// TODO: Create calorie entries preset system.

/// The app's name.
public let AppName = String(localized: "HealthVaults")
/// The app's bundle identifier.
public let AppID = Bundle.main.bundleIdentifier ?? "Debug.App"

// Widget IDs - Each widget type has its own unique identifier
public let BudgetWidgetID = "\(AppID).BudgetWidget"
public let MacrosWidgetID = "\(AppID).MacrosWidget"

/// The widgets bundle identifier (legacy - for compatibility).
public let WidgetsID = "\(AppID).Widgets"
/// The HealthKit observers bundle identifier.
public let ObserversID = "\(AppID).Observers"
/// The source code repository URL.
public let RepoURL = "https://github.com/mohdfareed/health-vaults"
