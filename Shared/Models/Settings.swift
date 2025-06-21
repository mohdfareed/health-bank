import Foundation
import SwiftData

// MARK: Definitions
// ============================================================================

/// The app color theme.
public enum AppTheme: String, SettingsValue, CaseIterable {
    case system, dark, light
}

/// The app's measurement system.
public typealias MeasurementSystem = Locale.MeasurementSystem
/// The app's first day of the week.
public typealias Weekday = Locale.Weekday

// MARK: Settings
// ============================================================================

/// The app settings as a static collection of keys.
extension Settings {
    /// The app theme.
    public static var theme: Settings<AppTheme> {
        .init("Theme", default: .system)
    }

    /// The app's unit measurement system.
    public static var unitSystem: Settings<MeasurementSystem?> {
        .init("MeasurementSystem", default: nil)
    }

    /// The app's first day of the week.
    public static var firstDayOfWeek: Settings<Weekday?> {
        .init("FirstWeekDay", default: nil)
    }

    /// The active user daily goals.
    public static var userGoals: Settings<UUID> {
        .init("Goals", default: .zero)
    }
}

// MARK: User Goals
// ============================================================================

/// The user's daily goals.
@Model public final class UserGoals: Singleton {
    public var date: Date = Date()

    // goals
    public var adjustment: Double? = nil  // in kcal
    public var macros: CalorieMacros? = nil  // in percent

    // singleton
    public var id: UUID
    public required init(id: ID = .init()) { self.id = id }
}

// MARK: Resettable Settings
// ============================================================================

extension UserDefaults {
    /// Resets the app's resettable settings to their default values.
    public func resetSettings() {
        for settings in [
            AnySettings(.theme),
            .init(.unitSystem),
            .init(.firstDayOfWeek),
        ] {
            self.removeObject(forKey: settings.id)
        }
    }
}
