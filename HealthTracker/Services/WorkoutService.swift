import Foundation
import SwiftData

// MARK: Queries
// ============================================================================

extension RemoteQuery {
    static func workout(
        calories: CalorieQuery<Model>,
        types: [WorkoutType] = WorkoutType.allCases
    ) -> WorkoutQuery<Model> where Model: Workout {
        .init(calories: calories, types: types)
    }
}

// MARK: Local Queries
// ============================================================================

extension WorkoutQuery: CoreQuery where C: PersistentModel {
    var descriptor: FetchDescriptor<C> {
        let (from, to) = (self.calories.from, self.calories.to)
        let (min, max) = (self.calories.min, self.calories.max)
        let types = self.types
        return FetchDescriptor<C>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to
                    && $0.calories > min && $0.calories < max
                    && types.contains($0.type)
            },
            sortBy: [SortDescriptor(\.date)]
        )
    }
}
