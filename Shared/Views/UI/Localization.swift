import Foundation
import SwiftUI

// MARK: Settings
// ============================================================================

public let AppName = String(localized: "HealthVaults")

extension DataSource {
    public var localized: String {
        switch self {
        case .app:
            return AppName
        case .healthKit:
            return String(localized: "apple health").localizedCapitalized
        case .shortcuts:
            return String(localized: "shortcuts").localizedCapitalized
        case .foodNoms:
            return String(localized: "foodNoms").localizedCapitalized
        case .other(let name):
            return name
        }
    }
}

extension AppTheme {
    public var localized: String {
        switch self {
        case .system: return String(localized: "system").localizedCapitalized
        case .dark: return String(localized: "dark").localizedCapitalized
        case .light: return String(localized: "light").localizedCapitalized
        }
    }
}

extension Weekday {
    public var localized: String {
        switch self {
        case .sunday:
            return String(localized: "sunday").localizedCapitalized
        case .monday:
            return String(localized: "monday").localizedCapitalized
        case .tuesday:
            return String(localized: "tuesday").localizedCapitalized
        case .wednesday:
            return String(localized: "wednesday").localizedCapitalized
        case .thursday:
            return String(localized: "thursday").localizedCapitalized
        case .friday:
            return String(localized: "friday").localizedCapitalized
        case .saturday:
            return String(localized: "saturday").localizedCapitalized
        default: return self.rawValue.localizedCapitalized
        }
    }
    public var abbreviated: String {
        switch self {
        case .sunday: return String(localized: "sun").localizedCapitalized
        case .monday: return String(localized: "mon").localizedCapitalized
        case .tuesday: return String(localized: "tue").localizedCapitalized
        case .wednesday: return String(localized: "wed").localizedCapitalized
        case .thursday: return String(localized: "thu").localizedCapitalized
        case .friday: return String(localized: "fri").localizedCapitalized
        case .saturday: return String(localized: "sat").localizedCapitalized
        default: return self.rawValue.localizedCapitalized
        }
    }
}

extension MeasurementSystem {
    public var localized: String {
        switch self {
        case .metric: return String(localized: "metric").localizedCapitalized
        case .us: return String(localized: "us").localizedUppercase
        case .uk: return String(localized: "uk").localizedUppercase
        default: return self.rawValue.localizedCapitalized
        }
    }
}
