import SwiftUI

// MARK: `SwiftUI` Integration
// ============================================================================

/// A property wrapper to localize a measurement value using a unit definition.
@MainActor @propertyWrapper
struct LocalizedMeasurement<D: Dimension>: DynamicProperty {
    @AppLocale() internal var locale: Locale
    @Environment(\.unitService)
    private var service: UnitService
    private let animation: Animation  // REVIEW: test

    @Binding private var baseValue: Double  // the value in the base unit
    @State private var selectedUnit: D?  // the user selected unit

    /// The unit definition for the measurement.
    let definition: UnitDefinition<D>
    /// The localized unit for the measurement.
    var localizedUnit: D {
        self.service.unit(self.definition, for: self.locale)
    }

    /// The localized measurement.
    var wrappedValue: Measurement<D> {
        Measurement(
            value: self.baseValue, unit: self.definition.baseUnit
        ).converted(to: self.localizedUnit)
    }  // used for localized display
    var projectedValue: Self { self }

    /// The user-selected unit of the measurement.
    var unit: Binding<D> {
        .init(
            get: { self.selectedUnit ?? self.localizedUnit },
            set: { self.selectedUnit = $0 }
        ).animation(self.animation)
    }  // used by input fields

    /// The measurement value in the user-selected unit.
    var value: Binding<Double> {
        .init(
            get: { wrappedValue.converted(to: self.unit.wrappedValue).value },
            set: {
                let measurement = Measurement(
                    value: $0, unit: self.unit.wrappedValue
                ).converted(to: self.definition.baseUnit)
                self.baseValue = measurement.value
            }
        ).animation(self.animation)
    }  // used by input fields

    init(
        _ value: Binding<Double>, unit: D? = nil,
        definition: UnitDefinition<D>, animation: Animation = .default
    ) {
        self.selectedUnit = unit
        self.definition = definition
        self.animation = animation
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
