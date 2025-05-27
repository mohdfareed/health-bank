import HealthKit
import SwiftUI

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

extension Measurement<UnitDuration> {
    /// The measurement converted to a duration.
    var duration: Duration {
        .seconds(self.converted(to: .seconds).value)
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
    @State var unit: D?

    let definition: UnitDefinition<D>
    var effectiveUnit: D { unit ?? definition.unit(for: locale) }

    var wrappedValue: Measurement<D> {
        Measurement(value: baseValue, unit: definition.baseUnit)
            .converted(to: effectiveUnit)
    }
    var projectedValue: Self { self }

    var value: Binding<Double> {
        Binding(
            get: { wrappedValue.value },
            set: { newValue in
                baseValue =
                    Measurement(value: newValue, unit: effectiveUnit)
                    .converted(to: definition.baseUnit).value
            }
        )
    }

    init(
        baseValue: Binding<Double>, definition: UnitDefinition<D>,
        animation: Animation = .default
    ) {
        self.definition = definition
        self._baseValue = baseValue.animation(animation)
        self._unit = State(initialValue: definition.unit(for: locale))
    }

    /// Provides a list of units suitable for user selection in a picker.
    func availableUnits() -> [D] {
        let displayUnit = definition.unit(for: locale)
        var units: [String: D] = [:]

        units[definition.baseUnit.symbol] = definition.baseUnit
        units[displayUnit.symbol] = displayUnit
        definition.altUnits.forEach { units[$0.symbol] = $0 }

        return units.values.sorted {
            $0.symbol.localizedCompare($1.symbol) == .orderedAscending
        }
    }
}
