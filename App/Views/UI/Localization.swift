import Foundation
import SwiftUI

// MARK: Settings
// ============================================================================

let AppName = String(localized: "HealthBank").localizedCapitalized

extension DataSource {
    var localized: String {
        switch self {
        case .local: return AppName
        case .healthKit:
            return String(localized: "apple health")
                .localizedCapitalized
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

extension WorkoutType {
    var localized: String {
        let name =
            switch self {
            case .walking, .running, .hiking, .stairClimbing, .elliptical,
                .mixedCardio, .mixedMetabolicCardioTraining,
                .highIntensityIntervalTraining:
                "cardio"
            case .functionalStrengthTraining, .traditionalStrengthTraining:
                "weight lifting"
            case .cycling:
                "cycling"
            case .dance, .danceInspiredTraining, .cardioDance, .socialDance:
                "dancing"
            case .boxing:
                "boxing"
            case .martialArts:
                "martial arts"
            default:
                "Workout"
            }
        return String(name).localizedCapitalized
    }
}
