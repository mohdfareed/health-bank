import HealthKit

extension HealthKitService {
    /// Returns the preferred unit for a single quantity type, converted to a Measurement-compatible Unit
    /// - Parameter quantityType: The HKQuantityType to get the preferred unit for
    /// - Returns: A Unit that can be used with the Measurement API
    @MainActor
    func preferredUnit(for quantityType: HKQuantityType) -> Unit? {
        Self.unitsCache[quantityType]
    }

    internal func setupUnits() async {
        await self.loadUnits()
        NotificationCenter.default.addObserver(
            forName: .HKUserPreferencesDidChange,
            object: nil,
            queue: .main
        ) { _ in
            Task {
                await self.loadUnits()
            }
        }
    }

    private func loadUnits() async {
        var units: [HKQuantityType: HKUnit] = [:]
        do {
            units = try await store.preferredUnits(
                for: Set(
                    HealthKitDataType.allCases.compactMap {
                        $0.sampleType as? HKQuantityType
                    })
            )
        } catch {
            let error = error.localizedDescription
            logger.error("Failed to load preferred units: \(error)")
            return
        }

        await MainActor.run {
            for (type, unit) in units {
                Self.unitsCache[type] = unit.measurementUnit
            }
        }
    }
}

extension UnitDuration {
    static var days: UnitDuration {
        return UnitDuration(
            symbol: "day",
            // 60 seconds * 60 minutes * 24 hours
            converter: UnitConverterLinear(coefficient: 86400)
        )
    }
}

extension HKUnit {
    /// Converts an HKUnit to a Measurement-compatible Unit
    var measurementUnit: Unit? {
        switch self {
        // Energy units
        case .kilocalorie():
            return UnitEnergy.kilocalories
        case .largeCalorie():
            return UnitEnergy.kilocalories
        case .smallCalorie():
            return UnitEnergy.calories
        case .joule():
            return UnitEnergy.joules

        // Mass units
        case .gram():
            return UnitMass.grams
        case .pound():
            return UnitMass.pounds
        case .ounce():
            return UnitMass.ounces
        case .stone():
            return UnitMass.stones
        case .gramUnit(with: .kilo):
            return UnitMass.kilograms

        // Duration units
        case .second():
            return UnitDuration.seconds
        case .minute():
            return UnitDuration.minutes
        case .hour():
            return UnitDuration.hours
        case .day():
            return UnitDuration.days

        default:
            // Fallback for unmapped units - create a custom unit
            AppLogger.new(for: HealthKitService.self).warning(
                "HKUnit \(self) not mapped to a Measurement Unit, using base."
            )
            return nil
        }
    }
}
