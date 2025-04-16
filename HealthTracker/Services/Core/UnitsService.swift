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
    @Environment(\.unitsService) var service
    @AppLocale var locale: Locale  // TODO: test moving to service.
    @Binding private var value: Double
    @State var unit: D = .baseUnit()
    let definition: UnitDefinition<D>
    // TODO: Animate.

    var wrappedValue: Measurement<D> {
        self.service.measurement(
            self.value, definition: self.definition, for: self.locale
        )
    }
    var projectedValue: Self { self }  // remove

    var measurement: (value: Binding<Double>, unit: Binding<D>) {
        let value = self.service.binding(
            value: self.$value, as: self.unit
        )
        return (value, $unit)
    }  // TODO: move into separate wrapper (UnitWriter) with its own state

    init(_ value: Binding<Double>, definition: UnitDefinition<D>) {
        self.definition = definition
        self._value = value
    }
}

// MARK: Service
// ============================================================================

// TODO: move unit definition and unit writer logic to the service.
// TODO:
struct UnitsService {
    /// The unit localization providers. Providers are mapped to their
    /// priority. The higher the number, the higher the priority.
    let providers: [Int: any UnitProvider]

    /// The localized measurement of a value.
    func measurement<D: Dimension>(
        _ value: Double, definition: UnitDefinition<D>, for locale: Locale
    ) -> Measurement<D> {
        let unit = self.unit(definition, for: locale)
        return Measurement(value: value, unit: .baseUnit()).converted(to: unit)
    }

    /// The localized measurement unit.
    func unit<D>(_ definition: UnitDefinition<D>, for locale: Locale) -> D
    where D: Dimension {
        if let unit = self.providedUnit(for: locale, usage: definition.usage) {
            return unit
        }
        if definition.usage == .asProvided {
            return definition.displayUnit
        }
        return definition.unit(for: locale)
    }

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

// MARK: Units Conversion
// ============================================================================

extension UnitsService {
    /// Create a binding of a value in a specific unit. when the new binding
    /// is read, the value is converted from its base unit to the new unit.
    /// When the new binding is written, the new value is converted from the
    /// new unit to the base unit.
    func binding<D>(value: Binding<Double>, as unit: D) -> Binding<Double>
    where D: Dimension {
        return Binding<Double>(
            get: {
                return Measurement<D>(
                    value: value.wrappedValue, unit: .baseUnit()
                ).converted(to: unit).value
            },
            set: {
                let meas = Measurement(value: $0, unit: unit)
                value.wrappedValue = meas.converted(to: .baseUnit()).value
            }
        )
    }
}

// MARK: Extensions
// ============================================================================

extension EnvironmentValues {
    /// The units localization service.
    @Entry var unitsService: UnitsService = UnitsService(providers: [:])
}

extension View {
    /// The units localization service.
    func unitsService(_ service: UnitsService) -> some View {
        self.environment(\.unitsService, service)
    }
}

extension UnitDefinition {
    internal func unit(for locale: Locale) -> D {
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

// MARK: Unit Definitions
// ============================================================================

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
