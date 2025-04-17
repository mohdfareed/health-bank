import SwiftUI

// MARK: `SwiftUI` Integration
// ============================================================================

/// A property wrapper to localize a measurement value using a unit definition.
@MainActor @propertyWrapper
struct LocalizedUnit<D: Dimension>: DynamicProperty {
    @Environment(\.unitService)
    internal var service: UnitService
    @AppLocale() internal var locale: Locale
    internal let definition: UnitDefinition<D>

    @Binding private var baseValue: Double  // value in base unit
    @State private var bindingUnit: D = .baseUnit()  // the binding value unit
    // REVIEW: Animate.

    var unit: Binding<D> { self.$bindingUnit }
    var value: Binding<Double> {
        self.service.binding(self.$baseValue, as: self.bindingUnit)
    }  // value binding in provided binding unit

    var wrappedValue: Measurement<D> {
        self.service.measurement(
            self.baseValue, self.definition, for: self.locale
        )
    }  // measurement in localized unit
    var projectedValue: Self { self }

    init(_ value: Binding<Double>, definition: UnitDefinition<D>) {
        self.definition = definition
        self._baseValue = value
    }
}

// MARK: Service
// ============================================================================

struct UnitService {
    /// The unit localization providers. Providers are mapped to their
    /// priority. The higher the number, the higher the priority.
    let providers: [Int: any UnitProvider]

    /// The localized measurement of a base-unit value.
    func measurement<D>(_ value: Double, in unit: D) -> Measurement<D>
    where D: Dimension {
        Measurement(value: value, unit: .baseUnit()).converted(to: unit)
    }

    /// The measurement of a base-unit value.
    func measurement<D: Dimension>(
        _ value: Double, _ definition: UnitDefinition<D>, for locale: Locale
    ) -> Measurement<D> {
        self.measurement(value, in: self.unit(definition, for: locale))
    }

    /// The localized measurement unit. Provided units are prioritized.
    /// If the unit's usage is `asProvided`, the display unit is used.
    func unit<D>(_ definition: UnitDefinition<D>, for locale: Locale) -> D
    where D: Dimension {
        let unit = self.providedUnit(for: locale, usage: definition.usage)
        if let unit = unit {
            return unit
        }  // prioritize provided units
        if definition.usage == .asProvided {
            return definition.displayUnit
        }  // use the display unit
        return definition.unit(for: locale)  // localized unit
    }

    /// Get the first unit provided, sorted by provider priority.
    private func providedUnit<D: Dimension>(
        for locale: Locale, usage: MeasurementFormatUnitUsage<D>
    ) -> D? {
        let priority = self.providers.keys.sorted(by: >)
        for p in priority {
            if let unit = self.providers[p]?.unit(locale, usage) {
                return unit
            }
        }
        return nil
    }
}

// MARK: Binding
// ============================================================================

extension UnitService {
    /// Create a binding of a base-unit value in the provided unit. when the
    /// binding is read, the value is converted from its base unit to the
    /// provided unit. When the binding is modified, the new value is converted
    /// from the provided unit to its base unit.
    internal func binding<D>(
        _ value: Binding<Double>, as unit: D
    ) -> Binding<Double>
    where D: Dimension {
        Binding<Double>(
            get: {  // base -> unit
                Measurement(value: value.wrappedValue, unit: .baseUnit())
                    .converted(to: unit).value
            },
            set: {  // unit -> base
                let meas = Measurement(value: $0, unit: unit)
                value.wrappedValue = meas.converted(to: .baseUnit()).value
            }
        )
    }

    /// Create a binding of a base-unit value in a localized unit.
    internal func binding<D>(
        _ value: Binding<Double>, _ definition: UnitDefinition<D>,
        for locale: Locale
    ) -> Binding<Double> where D: Dimension {
        self.binding(value, as: self.unit(definition, for: locale))
    }
}

// MARK: Formatting
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

// MARK: Extensions
// ============================================================================

extension EnvironmentValues {
    /// The units localization service.
    @Entry var unitService: UnitService = UnitService(providers: [:])
}

extension View {
    /// The units localization service.
    func unitService(_ service: UnitService) -> some View {
        self.environment(\.unitService, service)
    }
}

// MARK: Definitions
// ============================================================================

extension UnitDefinition {
    /// The localized unit for a specific locale.
    internal func unit(for locale: Locale) -> D {
        AppLogger.new(for: Self.self).warning(
            "Unit localization not implemented for: \(D.self)"
        )  // use base unit if not localized
        return .baseUnit()
    }
}

extension UnitDefinition {
    internal func unit(for locale: Locale) -> D where D == UnitDuration {
        return .init(forLocale: locale)
    }
    internal func unit(for locale: Locale) -> D where D == UnitEnergy {
        return .init(forLocale: locale, usage: self.usage)
    }
    internal func unit(for locale: Locale) -> D where D == UnitLength {
        return .init(forLocale: locale, usage: self.usage)
    }
    internal func unit(for locale: Locale) -> D where D == UnitMass {
        return .init(forLocale: locale, usage: self.usage)
    }
    internal func unit(for locale: Locale) -> D where D == UnitVolume {
        return .init(forLocale: locale, usage: self.usage)
    }
    internal func unit(for locale: Locale) -> D
    where D == UnitConcentrationMass {
        return .init(forLocale: locale)
    }
}
