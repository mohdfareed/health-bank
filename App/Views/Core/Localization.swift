import Foundation
import SwiftUI

// MARK: Settings
// ============================================================================

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

// MARK: Measurements
// ============================================================================

extension LocalizedMeasurement {
    /// The localization style of the current value.
    func formatted(
        as unit: D, base: Measurement<D>.FormatStyle? = nil
    ) -> String { self.wrappedValue.formatted(self.style(unit, base: base)) }

    /// The localization style of the current value.
    func formatted(
        base: Measurement<D>.FormatStyle? = nil
    ) -> String { self.wrappedValue.formatted(self.style(base: base)) }

    /// The localization style of the current value.
    func style(
        base: Measurement<D>.FormatStyle? = nil
    ) -> Measurement<D>.FormatStyle {
        let style = base ?? .init(width: .abbreviated)
        return style.localized(self.definition).locale(self.locale)
    }

    /// The localization style of the current value.
    func style(
        _ unit: D, base: Measurement<D>.FormatStyle? = nil
    ) -> Measurement<D>.FormatStyle {
        let style = base ?? .init(width: .abbreviated)
        return style.localized(as: unit).locale(self.locale)
    }
}

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
