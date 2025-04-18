import SwiftUI

// MARK: Units System
// ============================================================================

/// The unit localization definition. The unit is localized by default
/// unless usage is set to `asProvided`, then the display unit is used.
/// The units are resolved in the following order:
/// alternative (per view) -> display (per app) -> localized (per system)
struct UnitDefinition<D: Dimension> {
    /// The unit formatting usage.
    let usage: MeasurementFormatUnitUsage<D>
    /// The display unit to use if not localized.
    let displayUnit: D
    /// The alternative units allowed.
    let alternatives: [D]

    init(
        usage: MeasurementFormatUnitUsage<D> = .general,
        alternatives: [D] = []
    ) {
        self.usage = usage
        self.displayUnit = D.baseUnit()
        self.alternatives = alternatives
    }

    // init(.baseUnit()) is equivalent to init(.asProvided)
    init(unit: D, alternatives: [D] = []) {
        self.usage = .asProvided
        self.displayUnit = unit
        self.alternatives = alternatives
    }
}

/// A protocol for services that can provide a localized unit.
protocol UnitProvider {
    func unit<D: Dimension>(
        _ locale: Locale, _ usage: MeasurementFormatUnitUsage<D>
    ) -> D?  // nil if not supported or not available
}
