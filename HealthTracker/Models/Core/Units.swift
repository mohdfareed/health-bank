import Foundation

/// The unit localization definition. The unit is localized by default
/// unless usage is set to `asProvided`, then the display unit is used.
struct UnitDefinition<D: Dimension> {
    /// The unit formatting usage.
    var usage: MeasurementFormatUnitUsage<D>
    /// The display unit to use if not localized.
    let displayUnit: D

    init(usage: MeasurementFormatUnitUsage<D> = .general) {
        self.usage = usage
        self.displayUnit = D.baseUnit()
    }

    init(unit: D) {  // init(.baseUnit()) is equivalent to init(.asProvided)
        self.usage = .asProvided
        self.displayUnit = unit
    }
}

/// A protocol for services that can provide a localized unit.
protocol UnitProvider {
    func unit<D: Dimension>(
        _ locale: Locale, _ usage: MeasurementFormatUnitUsage<D>
    ) -> D?  // nil if not supported or not available
}
