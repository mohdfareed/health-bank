import Foundation

extension UnitDefinition where D == UnitEnergy {
    /// Generic calorie unit definition (kilocalories as base).
    static let calorie = UnitDefinition<UnitEnergy>(
        .kilocalories, healthKitType: .dietaryCalories, usage: .food,
    )
}

extension UnitDefinition where D == UnitMass {
    /// Protein unit definition (grams as base).
    static let macro = UnitDefinition<UnitMass>(
        .grams, healthKitType: .protein, usage: .asProvided
    )

    /// Weight unit definition (kilograms as base).
    static let weight = UnitDefinition<UnitMass>(
        .kilograms, alts: [.pounds, .stones], healthKitType: .bodyMass,
        usage: .personWeight,
    )
}
extension UnitDefinition where D == UnitDuration {
    /// Activity duration unit definition (minutes as base).
    static let activity = UnitDefinition<UnitDuration>(
        .minutes, alts: [.seconds, .hours], healthKitType: .workout,
        usage: .asProvided,
    )
}
