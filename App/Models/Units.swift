import Foundation
import SwiftData
import SwiftUI

extension Weight {
    @MainActor var measurement: LocalizedMeasurement<UnitMass> {
        .init(
            .keyPath(self, \.weight),
            definition: .init(
                .kilograms, alts: [.pounds], usage: .personWeight
            )
        )
    }
}

extension Calorie where Self: AnyObject {
    @MainActor var measurement: LocalizedMeasurement<UnitEnergy> {
        .init(
            .keyPath(self, \.calories),
            definition: .init(.kilocalories, usage: .food)
        )
    }
}

extension DietaryEnergy {
    @MainActor var carbsMeasurement: LocalizedMeasurement<UnitMass> {
        .init(
            .keyPath(self, \.macros.carbs).defaulted(to: 0),
            definition: .init(.grams, usage: .asProvided)
        )
    }
    @MainActor var proteinMeasurement: LocalizedMeasurement<UnitMass> {
        .init(
            .keyPath(self, \.macros.protein).defaulted(to: 0),
            definition: .init(.grams, usage: .asProvided)
        )
    }
    @MainActor var fatMeasurement: LocalizedMeasurement<UnitMass> {
        .init(
            .keyPath(self, \.macros.fat).defaulted(to: 0),
            definition: .init(.grams, usage: .asProvided)
        )
    }
}

extension ActiveEnergy {
    @MainActor var durationMeasurement: LocalizedMeasurement<UnitDuration> {
        .init(
            .keyPath(self, \.duration).defaulted(to: 0),
            definition: .init(
                .minutes, alts: [.seconds, .hours], usage: .asProvided
            )
        )
    }
}
