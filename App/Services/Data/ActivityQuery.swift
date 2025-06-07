import Foundation
import HealthKit
import SwiftData

struct ActivityQuery: HealthQuery {
    @MainActor func fetch(
        from: Date, to: Date, limit: Int? = nil,
        store: HealthKitService
    ) async -> [ActiveEnergy] {
        let workoutSamples = await store.fetchWorkoutSamples(
            from: from, to: to, limit: limit
        )

        let workouts = workoutSamples.compactMap { workout in
            let sample = workout.statistics(
                for: HKQuantityType(.activeEnergyBurned)
            )?.sumQuantity()

            let caloriesInKcal = sample?.doubleValue(for: .kilocalorie()) ?? 0
            let calories = UnitDefinition.calorie.asBase(
                caloriesInKcal, from: .kilocalories
            )
            let duration = workout.duration / 60  // Convert seconds to minutes
            let activity = workout.workoutActivityType

            return ActiveEnergy(
                calories, date: workout.startDate,
                duration: duration, workout: .init(from: activity),
                isInternal: workout.sourceRevision.source.isInternal,
                id: workout.uuid
            )
        }

        let samples = await store.fetchActivitySamples(
            for: HKQuantityType(.dietaryEnergyConsumed),
            from: from, to: to, limit: limit
        )

        let calories: [ActiveEnergy] = samples.compactMap { sample in
            let caloriesInKcal = sample.quantity.doubleValue(
                for: .kilocalorie()
            )
            let calories = UnitDefinition.calorie.asBase(
                caloriesInKcal, from: .kilocalories
            )
            return ActiveEnergy(
                calories, date: sample.startDate,
                isInternal: sample.sourceRevision.source.isInternal,
                id: sample.uuid,
            )
        }

        return (calories + workouts).sorted { $0.date > $1.date }
    }
}

extension WorkoutActivity {
    fileprivate var hkActivity: HKWorkoutActivityType {
        switch self {
        case .cardio: return .traditionalStrengthTraining
        case .cycling: return .cycling
        case .swimming: return .swimming
        case .weightlifting: return .traditionalStrengthTraining
        case .dancing: return .cardioDance
        case .martialArts: return .martialArts
        case .boxing: return .boxing
        }
    }

    fileprivate init?(from hkActivity: HKWorkoutActivityType) {
        switch hkActivity {
        case .traditionalStrengthTraining, .functionalStrengthTraining:
            self = .weightlifting
        case .cycling:
            self = .cycling
        case .swimming:
            self = .swimming
        case .dance, .danceInspiredTraining, .cardioDance, .socialDance:
            self = .dancing
        case .martialArts:
            self = .martialArts
        case .boxing:
            self = .boxing
        default:
            return nil
        }
    }
}
