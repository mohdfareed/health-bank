import SwiftUI

extension UnitDefinition {
    /// The localized unit for a specific locale.
    func unit(for locale: Locale) -> D {
        if self.usage == .asProvided {
            return self.baseUnit
        }

        if let unit = nativeUnit(for: locale, usage: self.usage) {
            return unit
        }

        AppLogger.new(for: Self.self).warning(
            "Unit localization not implemented for: \(D.self)"
        )  // use base unit if not localized
        return self.baseUnit
    }
}

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
    case is MeasurementFormatUnitUsage<UnitConcentrationMass>:
        return UnitConcentrationMass(forLocale: locale) as? D
    default: return nil
    }
}
