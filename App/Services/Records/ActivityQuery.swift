import Foundation
import HealthKit

struct ActivityQuery: HealthQuery {
    @MainActor
    func fetch(
        from: Date, to: Date, store: HealthKitService
    ) async -> [ActiveEnergy] {
        let workouts = await store.fetchWorkouts(from: from, to: to)
        return workouts.map { workout in
            let sample = workout.statistics(
                for: HKQuantityType(.activeEnergyBurned)
            )?.sumQuantity()

            let caloriesInKcal = sample?.doubleValue(for: .kilocalorie()) ?? 0
            let calories = UnitDefinition.calorie.asBase(
                caloriesInKcal, from: .kilocalories
            )
            let duration = workout.duration

            return ActiveEnergy(
                calories, date: workout.startDate,
                source: .healthKit, duration: duration,
            )
        }
    }

    func predicate(from: Date, to: Date) -> Predicate<ActiveEnergy> {
        return #Predicate<ActiveEnergy> {
            from <= $0.date && $0.date <= to
        }
    }
}
