import SwiftUI

// MARK: Service
// ============================================================================

struct UnitService {
    /// The unit localization providers. Providers are mapped to their
    /// priority. The higher the number, the higher the priority.
    let providers: [Int: any UnitProvider]

    /// The localized measurement unit. Provided units are prioritized.
    /// If the unit's usage is `asProvided`, the display unit is used.
    func unit<D>(_ definition: UnitDefinition<D>, for locale: Locale) -> D
    where D: Dimension {
        if definition.usage == .asProvided {
            return definition.baseUnit
        }  // prioritize the base unit if not localized
        let unit = self.providedUnit(for: locale, usage: definition.usage)
        if let unit = unit { return unit }  // prioritize provided units
        return definition.unit(for: locale)  // localized unit
    }

    /// Get the first unit provided, sorted by provider priority.
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

// MARK: Extensions
// ============================================================================

extension EnvironmentValues {
    /// The units localization service.
    @Entry var unitService: UnitService = UnitService(providers: [:])
}

extension View {
    /// The units localization service.
    func unitService(_ service: UnitService) -> some View {
        self.environment(\.unitService, service)
    }
}

// MARK: Primitive Units
// ============================================================================

extension UnitDefinition {
    /// The localized unit for a specific locale.
    fileprivate func unit(for locale: Locale) -> D {
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
