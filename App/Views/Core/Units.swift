import Foundation
import SwiftData
import SwiftUI

@MainActor extension LocalizedMeasurement<UnitMass> {
    static func weight(_ value: Binding<Double?>) -> Self {
        .init(
            value,
            definition: UnitDefinition(
                .kilograms, alts: [.pounds], usage: .personWeight
            )
        )
    }
}

@MainActor extension LocalizedMeasurement<UnitEnergy> {
    static func calorie(_ value: Binding<Double?>) -> Self {
        .init(
            value,
            definition: UnitDefinition(.kilocalories, usage: .food)
        )
    }
}

@MainActor extension LocalizedMeasurement<UnitMass> {
    static func macro(_ value: Binding<Double?>) -> Self {
        .init(
            value,
            definition: UnitDefinition(.grams, usage: .asProvided)
        )
    }
}

@MainActor extension LocalizedMeasurement<UnitDuration> {
    static func activity(_ value: Binding<Double?>) -> Self {
        .init(
            value,
            definition: UnitDefinition(
                .minutes, alts: [.seconds, .hours], usage: .asProvided
            )
        )
    }
}
