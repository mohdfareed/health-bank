import Foundation
import SwiftUI

// MARK: Settings
// ============================================================================

let AppName = String(localized: "health bank").localizedCapitalized

extension DataSource {
    var localized: String {
        switch self {
        case .local: return AppName
        case .healthKit: return String(localized: "apple health").localizedCapitalized
        }
    }
}

extension AppTheme {
    var localized: String {
        switch self {
        case .system: return String(localized: "system").localizedCapitalized
        case .dark: return String(localized: "dark").localizedCapitalized
        case .light: return String(localized: "light").localizedCapitalized
        }
    }
}

extension Weekday {
    var localized: String {
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
    var abbreviated: String {
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
    var localized: String {
        switch self {
        case .metric: return String(localized: "metric").localizedCapitalized
        case .us: return String(localized: "us").localizedUppercase
        case .uk: return String(localized: "uk").localizedUppercase
        default: return self.rawValue.localizedCapitalized
        }
    }
}

// case cardio, weightlifting, cycling, walking, running, other
extension WorkoutType {
    var localized: String {
        switch self {
        case .cardio: return String(localized: "cardio").localizedCapitalized
        case .weightlifting:
            return String(localized: "weightlifting").localizedCapitalized
        case .cycling: return String(localized: "cycling").localizedCapitalized
        case .walking: return String(localized: "walking").localizedCapitalized
        case .running: return String(localized: "running").localizedCapitalized
        case .other: return String(localized: "other").localizedCapitalized
        }
    }
}

// MARK: Measurements
// ============================================================================

extension Measurement.FormatStyle where UnitType: Dimension {
    func localized(
        _ definition: UnitDefinition<UnitType>
    ) -> Measurement<UnitType>.FormatStyle {
        var style = self
        style.usage = self.usage ?? definition.usage
        return style
    }

    func localized(
        as unit: UnitType
    ) -> Measurement<UnitType>.FormatStyle {
        var style = self
        style.usage = .asProvided
        return style
    }
}
