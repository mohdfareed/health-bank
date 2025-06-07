import Foundation
import SwiftUI

// TODO: Fix forced capitalization.

// MARK: Settings
// ============================================================================

let AppName = String(localized: "HealthBank")

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

extension WorkoutActivity {
    var localized: String {
        switch self {
        case .cardio:
            return String(localized: "cardio").localizedCapitalized
        case .cycling:
            return String(localized: "cycling").localizedCapitalized
        case .swimming:
            return String(localized: "swimming").localizedCapitalized
        case .weightlifting:
            return String(localized: "weightlifting").localizedCapitalized
        case .dancing:
            return String(localized: "dancing").localizedCapitalized
        case .boxing:
            return String(localized: "boxing").localizedCapitalized
        case .martialArts:
            return String(localized: "martial arts").localizedCapitalized
        }

    }
}

extension HealthRecordCategory {
    var localized: String {
        switch self {
        case .dietary: return String(localized: "food").localizedCapitalized
        case .active: return String(localized: "activity").localizedCapitalized
        case .weight: return String(localized: "weight").localizedCapitalized
        }
    }
}
