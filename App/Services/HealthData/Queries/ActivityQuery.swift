import Foundation
import HealthKit
import SwiftData

// TODO: Implement interface. Auto associate new workout with samples on save/update.

struct ActivityQuery: HealthQuery {
    var workoutFilters: Set<WorkoutActivity>

    init(workoutFilter: WorkoutActivity? = nil) {
        if let filter = workoutFilter {
            self.workoutFilters = Set([filter])
        } else {
            self.workoutFilters = Set()
        }
    }

    init(workoutFilters: Set<WorkoutActivity>) {
        self.workoutFilters = workoutFilters
    }

    func save(_ data: ActiveEnergy, store: HealthKitService) async throws {

    }

    func delete(_ data: ActiveEnergy, store: HealthKitService) async throws {

    }

    func update(_ data: ActiveEnergy, store: HealthKitService) async throws {

    }

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
                calories,
                duration: duration, workout: .init(from: activity),
                id: workout.uuid,
                source: workout.sourceRevision.source.dataSource,
                date: workout.startDate,
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
                calories,
                id: sample.uuid,
                source: sample.sourceRevision.source.dataSource,
                date: sample.startDate,
            )
        }

        let allActivities = (calories + workouts).sorted { $0.date > $1.date }

        // Apply workout filters if specified
        if !workoutFilters.isEmpty {
            return allActivities.filter { activity in
                guard let workout = activity.workout else { return false }
                return workoutFilters.contains(workout)
            }
        }

        return allActivities
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
