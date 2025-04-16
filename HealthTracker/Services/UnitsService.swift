import Foundation
import SwiftData
import SwiftUI

// MARK: `SwiftUI` Integration
// ============================================================================

@MainActor @propertyWrapper
struct UnitMeasurement<D: Dimension>: DynamicProperty {
    @AppLocale var locale: Locale
    @Binding var value: Double
    let definition: UnitDefinition<D>

    var wrappedValue: Measurement<D> {
        get {
            Measurement(
                value: self.value,
                unit: self.definition.unit(for: self.locale)
            )
        }
        nonmutating set { self.value = newValue.baseValue }
    }

    var projectedValue: Binding<Measurement<D>> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }

    init(_ value: Binding<Double>, definition: UnitDefinition<D>) {
        self.definition = definition
        self._value = value
    }
}

// MARK: Extensions
// ============================================================================

extension Measurement where UnitType: Dimension {
    /// The value of the measurement in the base unit.
    var baseValue: Double {
        self.converted(to: UnitType.baseUnit()).value
    }

    /// Create a measurement with a value in the base unit of a dimension.
    init(_ baseValue: Double, dimension: UnitType.Type) {
        self.init(value: baseValue, unit: dimension.baseUnit())
    }
}

extension UnitDuration {
    // TODO: Test symbol width in formatted strings.
    class Days: UnitDuration, @unchecked Sendable {}
    class var days: UnitDuration {
        return Days(
            symbol: "d",
            converter: UnitConverterLinear(coefficient: 60 * 60 * 24)
        )
    }
}

extension UnitDefinition {
    init(
        _ displayUnit: D = D.baseUnit(),
        usage: MeasurementFormatUnitUsage<D> = .general
    ) {
        self.usage = usage
        self.displayUnit = displayUnit
    }

    /// The localized unit.
    func unit(for locale: Locale) -> D {
        AppLogger.new(for: Self.self).warning(
            "Unit localization not implemented for: \(D.self)"
        )
        return D.baseUnit()
    }
}

// MARK: Unit Definitions
// ============================================================================

extension UnitDefinition {
    func unit(for locale: Locale) -> D where D == UnitDuration {
        if self.usage == .asProvided { return self.displayUnit }
        return .init(forLocale: locale)
    }
    func unit(for locale: Locale) -> D where D == UnitEnergy {
        if self.usage == .asProvided { return self.displayUnit }
        return .init(forLocale: locale, usage: self.usage)
    }
    func unit(for locale: Locale) -> D where D == UnitLength {
        if self.usage == .asProvided { return self.displayUnit }
        return .init(forLocale: locale, usage: self.usage)
    }
    func unit(for locale: Locale) -> D where D == UnitMass {
        if self.usage == .asProvided { return self.displayUnit }
        return .init(forLocale: locale, usage: self.usage)
    }
    func unit(for locale: Locale) -> D where D == UnitVolume {
        if self.usage == .asProvided { return self.displayUnit }
        return .init(forLocale: locale, usage: self.usage)
    }
    func unit(for locale: Locale) -> D where D == UnitConcentrationMass {
        if self.usage == .asProvided { return self.displayUnit }
        return .init(forLocale: locale)
    }
}
