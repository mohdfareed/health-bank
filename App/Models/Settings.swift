import Foundation
import SwiftData

// MARK: Definitions
// ============================================================================

/// The app color theme.
enum AppTheme: String, SettingsValue, CaseIterable {
    case system, dark, light
}

/// The app's measurement system.
typealias MeasurementSystem = Locale.MeasurementSystem
/// The app's first day of the week.
typealias Weekday = Locale.Weekday

// MARK: Settings
// ============================================================================

/// The app settings as a static collection of keys.
extension Settings {
    /// The app theme.
    static var theme: Settings<AppTheme> { .init("Theme", default: .system) }

    /// The app's unit measurement system.
    static var unitSystem: Settings<MeasurementSystem?> {
        .init("MeasurementSystem", default: nil)
    }

    /// The app's first day of the week.
    static var firstDayOfWeek: Settings<Weekday?> {
        .init("FirstWeekDay", default: nil)
    }

    /// The active user daily goals.
    static var userGoals: Settings<UUID> {
        .init("Goals", default: .zero)
    }
}

// MARK: User Goals
// ============================================================================

/// The user's daily goals.
@Model final class UserGoals: Singleton {
    var date: Date = Date()

    // goals
    var calories: Double? = nil
    var macros: CalorieMacros? = nil

    // singleton
    var id: UUID
    required init(id: ID = .init()) { self.id = id }
}

// MARK: Resettable Settings
// ============================================================================

extension UserDefaults {
    /// Resets the app's resettable settings to their default values.
    func resetSettings() {
        for settings in [
            AnySettings(.theme),
            .init(.unitSystem),
            .init(.firstDayOfWeek),
        ] {
            self.removeObject(forKey: settings.id)
        }
    }
}
