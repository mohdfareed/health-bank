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

    @Binding private var baseValue: Double  // the value in its base unit
    @Binding private var displayUnit: D  // the value display unit
    // REVIEW: Animate.

    var wrappedValue: Measurement<D> {
        Measurement<D>(
            self.baseValue,
            unit: self.service.unit(self.definition, for: self.locale)
        )
    }

    var projectedValue: Binding<Measurement<D>> {
        .init(
            get: { self.wrappedValue.converted(to: self.displayUnit) },
            set: {
                self.baseValue = $0.converted(to: .baseUnit()).value
                self.displayUnit = $0.unit
            }
        )
    }

    init(
        _ value: Binding<Double>, unit: Binding<D>,
        definition: UnitDefinition<D>
    ) {
        self.definition = definition
        self._baseValue = value
        self._displayUnit = unit
    }
}

// MARK: Service
// ============================================================================

struct UnitService {
    /// The unit localization providers. Providers are mapped to their
    /// priority. The higher the number, the higher the priority.
    let providers: [Int: any UnitProvider]

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

// MARK: Formatting
// ============================================================================

extension LocalizedUnit {
    /// The localization style of the current value.
    func formatted(
        as unit: D, base: Measurement<D>.FormatStyle? = nil
    ) -> String {
        self.wrappedValue.converted(to: unit).formatted(self.style(base: base))
    }

    /// The localization style of the current value.
    func formatted(
        base: Measurement<D>.FormatStyle? = nil
    ) -> String {
        self.wrappedValue.formatted(self.style(base: base))
    }

    /// The localization style of the current value.
    func style(
        base: Measurement<D>.FormatStyle? = nil
    ) -> Measurement<D>.FormatStyle {
        self.service.style(self.definition, for: self.locale, base: base)
    }

    /// The localization style of the current value.
    func style(
        _ unit: D, base: Measurement<D>.FormatStyle? = nil
    ) -> Measurement<D>.FormatStyle {
        self.service.style(unit, for: self.locale, base: base)
    }
}

extension UnitService {
    /// The localization style of a base-unit value.
    func style<D: Dimension>(
        _ definition: UnitDefinition<D>,
        for locale: Locale, base: Measurement<D>.FormatStyle? = nil
    ) -> Measurement<D>.FormatStyle {
        var style = base ?? Measurement.FormatStyle(width: .abbreviated)
        style.usage = style.usage ?? definition.usage
        return style.locale(locale)
    }

    /// The localization style of a base-unit value.
    func style<D: Dimension>(
        _ unit: D, for locale: Locale, base: Measurement<D>.FormatStyle? = nil
    ) -> Measurement<D>.FormatStyle {
        var style = base ?? Measurement.FormatStyle(width: .abbreviated)
        style.usage = .asProvided
        return style.locale(locale)
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

extension Measurement where UnitType: Dimension {
    /// Create a measurement from a base unit value. Defaults to `baseUnit()`.
    init(_ base: Double, unit: UnitType? = nil) {
        self.init(value: value, unit: .baseUnit())
        if let unit = unit { self.convert(to: unit) }
    }
}

extension Measurement<UnitDuration> {
    /// The measurement converted to a duration.
    var duration: Duration {
        .seconds(self.converted(to: .baseUnit()).value)
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
