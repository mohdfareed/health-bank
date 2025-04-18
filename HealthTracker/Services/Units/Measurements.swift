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

    @State private var displayUnit: D?  // the value display unit
    @Binding private var baseValue: Double?  // the value in its base unit
    // REVIEW: Animate.

    var wrappedValue: Measurement<D> {
        Measurement(
            value: self.baseValue ?? .zero, unit: self.definition.baseUnit
        ).converted(to: self.localizedUnit)
    }  // used for display
    var projectedValue: Self { self }

    var unit: Binding<D?> {
        .init(get: { self.displayUnit }, set: { self.displayUnit = $0 })
    }

    var value: Binding<Double?> {
        .init(
            get: {
                guard self.baseValue != nil else { return nil }
                return wrappedValue.value
            },
            set: {
                guard let value = $0 else {
                    self.baseValue = nil
                    return
                }
                let measurement = Measurement(
                    value: value, unit: self.localizedUnit
                ).converted(to: self.definition.baseUnit)
                self.baseValue = measurement.value
            }
        )
    }  // used for input fields

    var localizedUnit: D {
        if let displayUnit = self.displayUnit { return displayUnit }
        return self.service.unit(self.definition, for: self.locale)
    }

    init(
        _ value: Binding<Double?>, unit: D? = nil,
        definition: UnitDefinition<D>
    ) {
        self.displayUnit = unit
        self.definition = definition
        self._baseValue = value
    }
}

// MARK: Extensions
// ============================================================================

extension Measurement<UnitDuration> {
    /// The measurement converted to a duration.
    var duration: Duration {
        .seconds(self.converted(to: .seconds).value)
    }
}
