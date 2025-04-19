import SwiftUI

// MARK: Locale
// ============================================================================

/// A property wrapper to access the app's locale, applying any user settings.
@MainActor @propertyWrapper
struct AppLocale: DynamicProperty {
    @Environment(\.locale)
    private var appLocale: Locale
    private var components: Locale.Components { .init(locale: self.appLocale) }
    private let animation: Animation? = nil  // REVIEW: Animate.

    @AppStorage(.unitSystem)
    private var unitSystem: MeasurementSystem?
    @AppStorage(.firstDayOfWeek)
    private var firstDayOfWeek: Weekday?

    var wrappedValue: Locale {
        var components = self.components
        components.firstDayOfWeek =
            self.firstDayOfWeek
            ?? components.firstDayOfWeek
        components.measurementSystem =
            self.unitSystem
            ?? components.measurementSystem
        return Locale(components: components)
    }
    var projectedValue: Self { self }
}

// MARK: Settings Bindings
// ============================================================================

extension AppLocale {
    var units: Binding<MeasurementSystem> {
        .init(
            get: { self.wrappedValue.measurementSystem },
            set: { self.unitSystem = $0 }
        )
    }
    var firstWeekDay: Binding<Weekday> {
        .init(
            get: { self.wrappedValue.firstDayOfWeek },
            set: { self.firstDayOfWeek = $0 }
        )
    }
}
