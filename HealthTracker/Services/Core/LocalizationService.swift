import Foundation
import OSLog
import SwiftData
import SwiftUI

// MARK: App Locale
// ============================================================================

/// A property wrapper to access the app's locale, applying any user settings.
@MainActor @propertyWrapper struct AppLocale: DynamicProperty {
    // REVIEW: Test environment reactive updates.
    @Environment(\.locale) private var appLocale: Locale
    private var components: Locale.Components { .init(locale: self.appLocale) }
    // REVIEW: Animate.
    private let animation: Animation? = nil

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
    /// The formatted string of the localized value.
    func formatted(
        _ style: Measurement<D>.FormatStyle? = nil
    ) -> String {
        return self.service.format(
            self.wrappedValue.value, definition: self.definition,
            for: self.locale, style: style
        )
    }

    /// The formatted string of the localized value in a specific unit.
    func formatted(
        as unit: D, _ style: Measurement<D>.FormatStyle? = nil,
    ) -> String {
        return self.service.format(
            self.wrappedValue.value, as: unit, definition: self.definition,
            for: self.locale, style: style
        )
    }
}

extension UnitsService {
    /// The formatted string of the localized value.
    func format<D: Dimension>(
        _ value: Double, definition: UnitDefinition<D>,
        for locale: Locale, style: Measurement<D>.FormatStyle? = nil
    ) -> String {
        let meas = self.measurement(value, definition, for: locale)
        var style = style ?? Measurement.FormatStyle(width: .abbreviated)
        style.usage = definition.usage
        return meas.formatted(style.locale(locale))
    }

    /// The formatted string of the localized value.
    func format<D: Dimension>(
        _ value: Double, as unit: D, definition: UnitDefinition<D>,
        for locale: Locale, style: Measurement<D>.FormatStyle? = nil
    ) -> String {
        let meas = self.measurement(value, definition, for: locale)
        var style = style ?? Measurement.FormatStyle(width: .abbreviated)
        style.usage = .asProvided
        return meas.converted(to: unit).formatted(style.locale(locale))
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
