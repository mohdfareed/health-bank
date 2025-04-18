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
        let unit = self.providedUnit(for: locale, usage: definition.usage)
        if let unit = unit {
            return unit
        }  // prioritize provided units
        if definition.usage == .asProvided {
            return definition.displayUnit
        }  // use the display unit
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
        AppLogger.new(for: Self.self).warning(
            "Unit localization not implemented for: \(D.self)"
        )  // use base unit if not localized
        return .baseUnit()
    }
}

extension UnitDefinition {
    fileprivate func unit(for locale: Locale) -> D where D == UnitDuration {
        return .init(forLocale: locale)
    }
    fileprivate func unit(for locale: Locale) -> D where D == UnitEnergy {
        return .init(forLocale: locale, usage: self.usage)
    }
    fileprivate func unit(for locale: Locale) -> D where D == UnitLength {
        return .init(forLocale: locale, usage: self.usage)
    }
    fileprivate func unit(for locale: Locale) -> D where D == UnitMass {
        return .init(forLocale: locale, usage: self.usage)
    }
    fileprivate func unit(for locale: Locale) -> D where D == UnitVolume {
        return .init(forLocale: locale, usage: self.usage)
    }
    fileprivate func unit(for locale: Locale) -> D
    where D == UnitConcentrationMass {
        return .init(forLocale: locale)
    }
}
