import Foundation
import SwiftData
import SwiftUI

// MARK: `SwiftUI` Integration
// ============================================================================

/// A property wrapper to localize a measurement with a unit definition.
/// Internally, the unit is managed as its dimension's base unit. Otherwise,
/// the value is displayed in the app's locale's unit.
@MainActor @propertyWrapper
struct LocalizedUnit<D: Dimension>: DynamicProperty {
    @AppLocale private var locale: Locale
    @Binding private var value: Double

    @State var unit: D = .baseUnit()
    let definition: UnitDefinition<D>
    // TODO: Animate.

    var wrappedValue: Measurement<D> {
        self.definition.measurement(self.value, for: self.locale)
    }
    var projectedValue: Self { self }

    var measurement: (value: Binding<Double>, unit: Binding<D>) {
        let value = Binding<Double>(
            get: {
                let measurement = Measurement<D>(value: self.value)
                return measurement.converted(to: self.unit).value
            },
            set: {
                let measurement = Measurement(value: $0, unit: self.unit)
                self.value = measurement.converted(to: .baseUnit()).value
            }
        )
        return (value, $unit)
    }

    init(_ value: Binding<Double>, definition: UnitDefinition<D>) {
        self.definition = definition
        self._value = value
    }

    /// The formatted string of the localized value.
    func formatted(
        _ style: Measurement<D>.FormatStyle? = nil
    ) -> String {
        return self.definition.format(
            self.wrappedValue.value, for: self.locale, style: style
        )
    }

    /// The formatted string of the localized value in a specific unit.
    func formatted(
        as unit: D, _ style: Measurement<D>.FormatStyle? = nil,
    ) -> String {
        return self.definition.format(
            self.wrappedValue.value, as: unit, for: self.locale, style: style
        )
    }
}

// MARK: Extensions
// ============================================================================

extension UnitDefinition {
    /// The measurement of the localized value.
    func measurement(_ value: Double, for locale: Locale) -> Measurement<D> {
        let unit = self.unit(for: locale)
        return Measurement<D>(value: value).converted(to: unit)
    }

    /// The formatted string of the localized value.
    func format(
        _ value: Double, for locale: Locale,
        style: Measurement<D>.FormatStyle? = nil
    ) -> String {
        let measurement = self.measurement(value, for: locale)
        var style = style ?? Measurement.FormatStyle(width: .abbreviated)
        style.usage = self.usage
        return measurement.formatted(style.locale(locale))
    }

    /// The formatted string of the localized value.
    func format(
        _ value: Double, as unit: D, for locale: Locale,
        style: Measurement<D>.FormatStyle? = nil
    ) -> String {
        let measurement = self.measurement(value, for: locale)
        var style = style ?? Measurement.FormatStyle(width: .abbreviated)
        style.usage = .asProvided
        return measurement.converted(to: unit).formatted(style.locale(locale))
    }

    /// The localized measurement unit.
    internal func unit(for locale: Locale) -> D {
        if self.usage == .asProvided { return self.displayUnit }
        AppLogger.new(for: Self.self).warning(
            "Unit localization not implemented for: \(D.self)"
        )
        return .baseUnit()
    }
}

extension Measurement where UnitType: Dimension {
    init(value: Double = 0) {
        self.init(value: value, unit: .baseUnit())
    }
}

// MARK: Custom Units
// ============================================================================

extension UnitDuration {
    // FIXME: Correct set `.wide` width to "days".
    class var days: UnitDuration {
        return UnitDuration(
            symbol: "d",  // 1d = 60s * 60m * 24h
            converter: UnitConverterLinear(coefficient: 60 * 60 * 24)
        )
    }
}

// MARK: Unit Definitions
// ============================================================================

extension UnitDefinition {
    func unit(for locale: Locale) -> D where D == UnitDuration {
        return .init(forLocale: locale)
    }
    func unit(for locale: Locale) -> D where D == UnitEnergy {
        return .init(forLocale: locale, usage: self.usage)
    }
    func unit(for locale: Locale) -> D where D == UnitLength {
        return .init(forLocale: locale, usage: self.usage)
    }
    func unit(for locale: Locale) -> D where D == UnitMass {
        return .init(forLocale: locale, usage: self.usage)
    }
    func unit(for locale: Locale) -> D where D == UnitVolume {
        return .init(forLocale: locale, usage: self.usage)
    }
    func unit(for locale: Locale) -> D where D == UnitConcentrationMass {
        return .init(forLocale: locale)
    }
}
