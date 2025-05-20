import SwiftUI

// MARK: `SwiftUI` Integration
// ============================================================================

/// A property wrapper to localize a measurement value using a unit definition.
@MainActor @propertyWrapper
struct LocalizedMeasurement<D: Dimension>: DynamicProperty {
    @AppLocale() internal var locale: Locale
    @Environment(\.unitService) private var service: UnitService
    @Binding var baseValue: Double  // the value in the base unit

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

    init(
        _ value: Binding<Double>, definition: UnitDefinition<D>,
        animation: Animation = .default
    ) {
        self._baseValue = value.animation(animation)
        self.definition = definition
    }

    /// Set the value of the measurement. Default to the localized unit.
    func update(_ value: Double, unit: D? = nil) {
        let meas = Measurement(value: value, unit: unit ?? self.localizedUnit)
        self.baseValue = meas.converted(to: self.definition.baseUnit).value
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
