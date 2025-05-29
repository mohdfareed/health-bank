import SwiftUI

/// A property wrapper to localize a measurement value using a unit definition.
/// It allows for displaying values in a locale-appropriate unit and supports
/// user overrides for the display unit.
@MainActor @propertyWrapper
struct LocalizedMeasurement<D: Dimension>: DynamicProperty {
    @AppLocale var locale
    @Binding var baseValue: Double?
    @State var displayUnit: D?
    let definition: UnitDefinition<D>

    var wrappedValue: Measurement<D> {
        get {
            return Measurement(
                value: baseValue ?? 0, unit: definition.baseUnit
            )
            .converted(to: unit.wrappedValue)
        }
        nonmutating set {
            baseValue = newValue.converted(to: definition.baseUnit).value
        }
    }
    var projectedValue: Self { self }

    var value: Binding<Double?> {
        Binding(
            get: { wrappedValue.value },
            set: {
                wrappedValue = Measurement(
                    value: $0 ?? 0, unit: unit.wrappedValue
                )
            }
        )
    }

    var unit: Binding<D> {
        Binding(
            get: { displayUnit ?? definition.unit(for: locale) },
            set: { displayUnit = $0 }
        )
    }

    init(_ value: Binding<Double>, definition: UnitDefinition<D>) {
        self.definition = definition
        self._baseValue = value.optional(0)
        self._displayUnit = State(initialValue: definition.unit(for: locale))
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

extension Measurement<UnitDuration> {
    /// The measurement converted to a duration.
    var duration: Duration {
        .seconds(self.converted(to: .seconds).value)
    }
}
