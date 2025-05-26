import HealthKit
import SwiftUI

// MARK: Measurements
// ============================================================================

private struct LocalizedMeasurementValue<D: Dimension> {
    let definition: UnitDefinition<D>
    let locale: Locale
    let overrideUnit: D?
    var effectiveUnit: D {
        overrideUnit ?? definition.unit(for: locale)
    }

    func toDisplayValue(base: Double) -> Measurement<D> {
        Measurement(value: base, unit: definition.baseUnit).converted(to: effectiveUnit)
    }

    func toBaseValue(display: Double, in unit: D?) -> Double {
        let inputUnit = unit ?? effectiveUnit
        return Measurement(value: display, unit: inputUnit).converted(to: definition.baseUnit).value
    }

    func availableUnits() -> [D] {
        var units: Set<D> = [
            definition.baseUnit,
            definition.unit(for: locale),
        ]
        definition.altUnits.forEach { units.insert($0) }

        return units.sorted {
            $0.symbol.localizedCompare($1.symbol) == .orderedAscending
        }
    }
}

extension Measurement<UnitDuration> {
    /// The measurement converted to a duration.
    var duration: Duration {
        .seconds(self.converted(to: .seconds).value)
    }
}

// MARK: Units
// ============================================================================

extension UnitDefinition {
    /// The localized unit for a specific locale.
    func unit(for locale: Locale) -> D {
        if self.usage == .asProvided {
            return self.baseUnit
        }

        if let unit = nativeUnit(for: locale, usage: self.usage) {
            return unit
        }

        AppLogger.new(for: Self.self).warning(
            "Unit localization not implemented for: \(D.self)"
        )  // use base unit if not localized
        return self.baseUnit
    }
}

private func nativeUnit<D: Dimension>(
    for locale: Locale, usage: MeasurementFormatUnitUsage<D>
) -> D? {
    switch usage {
    case is MeasurementFormatUnitUsage<UnitDuration>:
        return UnitDuration(forLocale: locale) as? D
    case let usage as MeasurementFormatUnitUsage<UnitEnergy>:
        return UnitEnergy(forLocale: locale, usage: usage) as? D
    case let usage as MeasurementFormatUnitUsage<UnitLength>:
        return UnitLength(forLocale: locale, usage: usage) as? D
    case let usage as MeasurementFormatUnitUsage<UnitMass>:
        return UnitMass(forLocale: locale, usage: usage) as? D
    case let usage as MeasurementFormatUnitUsage<UnitVolume>:
        return UnitVolume(forLocale: locale, usage: usage) as? D
    case let usage as MeasurementFormatUnitUsage<UnitSpeed>:
        return UnitSpeed(forLocale: locale, usage: usage) as? D
    case is MeasurementFormatUnitUsage<UnitConcentrationMass>:
        return UnitConcentrationMass(forLocale: locale) as? D
    default: return nil
    }
}

// MARK: `SwiftUI` Integration
// ============================================================================

/// A property wrapper to localize a measurement value using a unit definition.
/// It allows for displaying values in a locale-appropriate unit and supports
/// user overrides for the display unit.
@MainActor @propertyWrapper
struct LocalizedMeasurement<D: Dimension>: DynamicProperty {
    @AppLocale var locale
    @Binding var baseValue: Double
    @Binding var overrideUnit: D?

    let definition: UnitDefinition<D>
    private var adapter: LocalizedMeasurementValue<D> {
        .init(definition: definition, locale: locale, overrideUnit: overrideUnit)
    }

    var wrappedValue: Measurement<D> {
        adapter.toDisplayValue(base: baseValue)
    }
    var projectedValue: Self { self }

    init(
        baseValue: Binding<Double>,
        definition: UnitDefinition<D>,
        overrideUnit: Binding<D?>,
        animation: Animation = .default
    ) {
        self._baseValue = baseValue.animation(animation)
        self._overrideUnit = overrideUnit
        self.definition = definition
    }

    /// Update the `baseValue` from an input value provided in a specific unit.
    func update(_ inputValue: Double, unit: D? = nil) {
        baseValue = adapter.toBaseValue(display: inputValue, in: unit)
    }

    /// Provides a list of units suitable for user selection in a picker.
    func availableUnits() -> [D] {
        adapter.availableUnits()
    }
}
