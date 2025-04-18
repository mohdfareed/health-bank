import SwiftUI

// MARK: `SwiftUI` Integration
// ============================================================================

/// A property wrapper to localize a measurement value using a unit definition.
@MainActor @propertyWrapper
struct LocalizedMeasurement<D: Dimension>: DynamicProperty {
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
    }  // used for display

    var projectedValue: Binding<Measurement<D>> {
        .init(
            get: { self.wrappedValue.converted(to: self.displayUnit) },
            set: {
                self.baseValue = $0.converted(to: .baseUnit()).value
                self.displayUnit = $0.unit
            }
        )
    }  // used for input fields

    init(
        _ value: Binding<Double>, unit: Binding<D>,
        definition: UnitDefinition<D>
    ) {
        self.definition = definition
        self._baseValue = value
        self._displayUnit = unit
    }
}

// MARK: Extensions
// ============================================================================

extension Measurement where UnitType: Dimension {
    /// Create a measurement from a base unit value. Defaults to `baseUnit()`.
    init(_ base: Double, unit: UnitType? = nil) {
        self.init(value: base, unit: .baseUnit())
        if let unit = unit { self.convert(to: unit) }
    }
}

extension Measurement<UnitDuration> {
    /// The measurement converted to a duration.
    var duration: Duration {
        .seconds(self.converted(to: .seconds).value)
    }
}

// MARK: Localization
// ============================================================================

extension LocalizedMeasurement {
    /// The localization style of the current value.
    func formatted(
        as unit: D, base: Measurement<D>.FormatStyle? = nil
    ) -> String { self.wrappedValue.formatted(self.style(unit, base: base)) }

    /// The localization style of the current value.
    func formatted(
        base: Measurement<D>.FormatStyle? = nil
    ) -> String { self.wrappedValue.formatted(self.style(base: base)) }

    /// The localization style of the current value.
    func style(
        base: Measurement<D>.FormatStyle? = nil
    ) -> Measurement<D>.FormatStyle {
        let style = base ?? .init(width: .abbreviated)
        return style.localized(self.definition).locale(self.locale)
    }

    /// The localization style of the current value.
    func style(
        _ unit: D, base: Measurement<D>.FormatStyle? = nil
    ) -> Measurement<D>.FormatStyle {
        let style = base ?? .init(width: .abbreviated)
        return style.localized(as: unit).locale(self.locale)
    }
}

extension Measurement.FormatStyle where UnitType: Dimension {
    func localized(
        _ definition: UnitDefinition<UnitType>
    ) -> Measurement<UnitType>.FormatStyle {
        var style = self
        style.usage = self.usage ?? definition.usage
        return style
    }

    func localized(
        as unit: UnitType
    ) -> Measurement<UnitType>.FormatStyle {
        var style = self
        style.usage = .asProvided
        return style
    }
}
