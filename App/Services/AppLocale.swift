import SwiftUI

// FIXME: not working, env locale used outside of view

// MARK: Locale
// ============================================================================

/// A property wrapper to access the app's locale, applying any user settings.
@MainActor @propertyWrapper
struct AppLocale: DynamicProperty {
    @AppStorage(.unitSystem) private var unitSystem: MeasurementSystem?
    @AppStorage(.firstDayOfWeek) private var firstDayOfWeek: Weekday?
    @Environment(\.locale) private var systemLocale: Locale

    /// The computed locale combining system and user settings.
    var wrappedValue: Locale {
        var components = Locale.Components(locale: systemLocale)
        components.firstDayOfWeek = firstDayOfWeek ?? components.firstDayOfWeek
        components.measurementSystem = unitSystem ?? components.measurementSystem
        return Locale(components: components)
    }

    /// Exposes bindings to user settings for use in SwiftUI.
    var projectedValue: AppLocale { self }

    /// Binding for measurement system setting.
    var units: Binding<MeasurementSystem> {
        Binding(
            get: { unitSystem ?? systemLocale.measurementSystem },
            set: { unitSystem = $0 }
        )
    }

    /// Binding for first day of week setting.
    var firstWeekDay: Binding<Weekday> {
        Binding(
            get: { firstDayOfWeek ?? systemLocale.firstDayOfWeek },
            set: { firstDayOfWeek = $0 }
        )
    }
}

/// A view modifier to apply the app's locale, based on user settings.
struct AppLocaleModifier: ViewModifier {
    @AppStorage(.unitSystem) private var unitSystem: MeasurementSystem?
    @AppStorage(.firstDayOfWeek) private var firstDayOfWeek: Weekday?
    @Environment(\.locale) private var systemLocale: Locale

    private var locale: Locale {
        var components = Locale.Components(locale: systemLocale)
        components.firstDayOfWeek = firstDayOfWeek ?? components.firstDayOfWeek
        components.measurementSystem = unitSystem ?? components.measurementSystem
        return Locale(components: components)
    }

    func body(content: Content) -> some View {
        content.environment(\.locale, locale)
    }
}

extension View {
    /// Applies the app's locale settings to this view hierarchy.
    func appLocale() -> some View {
        self.modifier(AppLocaleModifier())
    }
}
