import Foundation

extension Weight {
    /// The unit for a weight record.
    static var unit: UnitDefinition<UnitMass> {
        .init(.kilograms, alts: [.pounds], usage: .personWeight)
    }
}

extension DietaryEnergy {
    /// The unit for calorie values.
    static var unit: UnitDefinition<UnitEnergy> {
        .init(.kilocalories, usage: .food)
    }
}

extension CalorieMacros {
    /// The unit for a calorie macros breakdown.
    static var unit: UnitDefinition<UnitMass> {
        .init(.grams, usage: .asProvided)
    }
}

extension ActiveEnergy {
    /// The unit for a workout duration.
    static var unit: UnitDefinition<UnitDuration> {
        .init(.minutes, alts: [.seconds, .hours], usage: .general)
    }
}
