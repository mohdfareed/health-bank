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

        let workouts = workoutSamples.map { workout in
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
                source: workout.sourceRevision.source.dataSource,
                duration: duration, workout: .init(from: activity)
            )
        }

        let samples = await store.fetchQuantitySamples(
            for: HKQuantityType(.activeEnergyBurned),
            from: from, to: to, limit: limit
        )

        let calories: [ActiveEnergy] = samples.compactMap { sample in
            // check if sample already in workouts
            if workoutSamples.contains(where: {
                $0.startDate <= sample.startDate
                    && $0.endDate >= sample.endDate
            }) {
                return nil
            }

            let caloriesInKcal = sample.quantity.doubleValue(
                for: .kilocalorie()
            )
            let calories = UnitDefinition.calorie.asBase(
                caloriesInKcal, from: .kilocalories
            )
            return ActiveEnergy(
                calories, date: sample.startDate,
                source: sample.sourceRevision.source.dataSource
            )
        }

        // Combine the calories from workouts and samples
        return calories + workouts
    }

    func descriptor(from: Date, to: Date) -> FetchDescriptor<ActiveEnergy> {
        let predicate = #Predicate<ActiveEnergy> {
            from <= $0.date && $0.date <= to
        }
        return FetchDescriptor(
            predicate: predicate,
            sortBy: [.init(\.date, order: .reverse)]
        )
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
