import SwiftUI

// MARK: App Locale
// ============================================================================

/// A property wrapper to access the app's locale, applying any user settings.
@MainActor @propertyWrapper
struct AppLocale: DynamicProperty {
    @Environment(\.locale)
    private var appLocale: Locale
    private var components: Locale.Components { .init(locale: self.appLocale) }
    private let animation: Animation? = nil  // REVIEW: Animate.

    @AppStorage(AppSettings.unitSystem)
    var unitSystem: Locale.MeasurementSystem?
    @AppStorage(AppSettings.firstDayOfWeek)
    var firstDayOfWeek: Locale.Weekday?

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

// MARK: Units Formatting
// ============================================================================

extension LocalizedUnit {
    /// The localized string of a base-unit value.
    func formatted(
        as unit: D? = nil, _ style: Measurement<D>.FormatStyle? = nil
    ) -> String {
        self.service.format(
            self.wrappedValue.value, as: unit, definition: self.definition,
            for: self.locale, style: style
        )
    }

    /// The localized string of a duration base-unit value.
    func formatted(_ style: Duration.UnitsFormatStyle) -> String
    where D == UnitDuration {
        self.service.format(
            self.wrappedValue.value, for: self.locale, style: style
        )
    }
}

extension UnitService {
    /// The localized string of a base-unit value.
    func format<D: Dimension>(
        _ value: Double, as unit: D? = nil, definition: UnitDefinition<D>,
        for locale: Locale, style: Measurement<D>.FormatStyle? = nil
    ) -> String {
        var meas = self.measurement(value, definition, for: locale)
        var style = style ?? Measurement.FormatStyle(width: .abbreviated)
        if let unit = unit {
            meas = meas.converted(to: unit)
            style.usage = .asProvided
        }
        return meas.formatted(style.locale(locale))
    }

    /// The localized string of a duration base-unit value.
    func format(
        _ value: Double, for locale: Locale, style: Duration.UnitsFormatStyle
    ) -> String {
        let meas = Measurement<UnitDuration>(value: value, unit: .baseUnit())
        let seconds = meas.converted(to: UnitDuration.seconds).value
        let duration = Duration.seconds(seconds)
        return duration.formatted(style)
    }
}

// MARK: Settings
// ============================================================================

// Support `Weekday` in app storage.
extension Locale.Weekday: SettingsValue {}

// Support `MeasurementSystem` in app storage.
extension Locale.MeasurementSystem: SettingsValue {}
extension Locale.MeasurementSystem: @retroactive RawRepresentable {
    public var rawValue: String { self.identifier }
    public init?(rawValue: String) { self.init(rawValue) }
}
