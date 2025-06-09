import Foundation

extension UnitDefinition where D == UnitEnergy {
    /// Generic calorie unit definition (kilocalories as base).
    static let calorie = UnitDefinition<UnitEnergy>(
        .kilocalories,
        usage: .food,
        healthKitType: .dietaryCalories,
    )
}

extension UnitDefinition where D == UnitMass {
    /// Protein unit definition (grams as base).
    static let macro = UnitDefinition<UnitMass>(
        .grams,
        usage: .asProvided,
        healthKitType: .protein,
    )

    /// Weight unit definition (kilograms as base).
    static let weight = UnitDefinition<UnitMass>(
        .kilograms, alts: [.pounds, .stones],
        usage: .personWeight,
        healthKitType: .bodyMass,
    )
}

extension UnitDefinition where D == UnitVolume {
    /// Alcohol contents unit definition (standard drink as base).
    static let alcohol = UnitDefinition<UnitVolume>(
        .milliliters,
        alts: [.milliliters, .fluidOunces, .standardDrink],
        usage: .liquid,
        healthKitType: .alcohol,
    )
}

extension UnitMass {
    /// Standard drink unit definition (14 grams of alcohol).
    static let standardDrink = UnitMass(
        symbol: "stdDr",
        converter: UnitConverterLinear(coefficient: 14)
    )
}

extension UnitVolume {
    /// Standard drink unit definition (17.7 milliliters of pure alcohol).
    static let standardDrink = UnitVolume(
        symbol: "stdDr",
        converter: UnitConverterLinear(coefficient: 17.7)
    )
}

extension UnitDuration {
    /// A unit for representing days, based on seconds.
    static var days: UnitDuration {
        return UnitDuration(
            symbol: "d",
            // 60 seconds * 60 minutes * 24 hours
            converter: UnitConverterLinear(coefficient: 60 * 60 * 24)
        )
    }

    /// A unit for representing weeks, based on seconds.
    static var weeks: UnitDuration {
        return UnitDuration(
            symbol: "w",
            // 60 seconds * 60 minutes * 24 hours * 7 days
            converter: UnitConverterLinear(coefficient: 60 * 60 * 24 * 7)
        )
    }
}
