import HealthKit
import SwiftUI

extension Measurement<UnitEnergy> {
    /// Convert the energy as calories to body mass as 1 kg = 7700 kcal.
    static let caloriesToMassFactor: Double = 7700.0

    func asMass() -> Measurement<UnitMass> {
        let calories = self.converted(to: .kilocalories).value
        let mass = calories / Self.caloriesToMassFactor
        return .init(value: mass, unit: .kilograms)
    }
}

extension Measurement<UnitMass> {
    /// Convert the energy as calories to body mass as 1 kg = 7700 kcal.
    static let caloriesToMassFactor: Double = 7700.0

    func asEnergy() -> Measurement<UnitEnergy> {
        let mass = self.converted(to: .kilograms).value
        let calories = mass * Self.caloriesToMassFactor
        return .init(value: calories, unit: .kilocalories)
    }
}

// MARK: Localization
// ============================================================================

extension UnitDefinition {
    /// Convert the value from the given unit to the base unit.
    func asBase(_ value: Double, from unit: D) -> Double {
        Measurement(value: value, unit: unit)
            .converted(to: self.baseUnit).value
    }

    /// The localized unit for a specific locale.
    func unit(for locale: Locale) -> D {
        if self.usage == .asProvided {
            return self.baseUnit
        }

        if let unit = nativeUnit(for: locale, usage: self.usage) {
            return unit
        }

        AppLogger.new(for: Self.self).warning(
            "Unit not localized: \(D.self)"
        )  // use base unit if not localized
        return self.baseUnit
    }
}

// MARK: Supported Units
// ============================================================================

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
    default:
        // For unsupported dimensions, return nil
        AppLogger.new(for: UnitDefinition.self).warning(
            "Unsupported unit type: \(D.self)"
        )
        return nil
    }
}

// MARK: SwiftUI Integration
// ============================================================================

/// A property wrapper to localize a measurement value using a unit definition.
/// It allows for displaying values in a locale-appropriate unit and supports
/// user overrides for the display unit.
@MainActor @propertyWrapper
struct LocalizedMeasurement<D: Dimension>: DynamicProperty {
    @AppLocale private var locale
    @Environment(\.healthKit)
    var healthKitService: HealthKitService

    @Binding var baseValue: Double?
    @State var displayUnit: D?
    let definition: UnitDefinition<D>

    var value: Binding<Double?> {
        Binding(
            get: { baseValue != nil ? wrappedValue.value : nil },
            set: {
                guard let value = $0 else {
                    baseValue = nil
                    return
                }
                wrappedValue = Measurement(
                    value: value,
                    unit: unit.wrappedValue ?? definition.baseUnit
                )
            }
        )
    }

    var unit: Binding<D?> {
        Binding(
            get: {
                // 1) User override
                if let override = displayUnit {
                    return override
                }

                // 2) App Settings preferred unit
                if $locale.units.wrappedValue != nil {
                    return definition.unit(for: locale)
                }

                // 3) HealthKit preferred unit
                let type = definition.healthKitType?.quantityType
                let unitOf = healthKitService.preferredUnit
                if let hkUnit = unitOf(type) as? D {
                    return hkUnit
                }

                // 4) Default localization
                return definition.unit(for: locale)
            },
            set: { displayUnit = $0 }
        )
    }

    var wrappedValue: Measurement<D> {
        get {
            return Measurement(
                value: baseValue ?? 0, unit: definition.baseUnit
            )
            .converted(to: unit.wrappedValue ?? definition.baseUnit)
        }
        nonmutating set {
            baseValue = newValue.converted(to: definition.baseUnit).value
        }
    }
    var projectedValue: Self { self }

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

// MARK: Initializers
// ============================================================================

extension LocalizedMeasurement {
    init(_ value: Binding<Double?>, definition: UnitDefinition<D>) {
        self.definition = definition
        self._baseValue = value
    }

    init(
        _ value: Binding<Double>, definition: UnitDefinition<D>,
        defaultValue: Double? = nil
    ) { self.init(value.optional(defaultValue ?? 0), definition: definition) }
}
