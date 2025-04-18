import Foundation
import SwiftData

// MARK: Calorie Models
// ============================================================================

@Model final class CoreNutritionCalorie: NutritionCalorie {
    var source = DataSource()
    var date: Date
    var calories: Double
    var macros: CalorieMacros?
    init(_ calories: Double, macros: CalorieMacros? = nil, on date: Date) {
        self.date = date
        self.calories = calories
        self.macros = macros
    }
}

@Model final class CoreRestingCalorie: RestingCalorie {
    var source = DataSource()
    var date: Date
    var calories: Double
    init(_ calories: Double, on date: Date) {
        self.date = date
        self.calories = calories
    }
}

@Model final class ExerciseCalorie: ActivityCalorie {
    var source = DataSource()
    var date: Date
    var calories: Double
    var duration: TimeInterval
    init(_ calories: Double, over duration: TimeInterval, on date: Date) {
        self.date = date
        self.calories = calories
        self.duration = duration
    }
}

// MARK: Calories Queries
// ============================================================================

extension CalorieQuery: CoreQuery where C: PersistentModel {
    var descriptor: FetchDescriptor<C> {
        let (from, to) = (self.from, self.to)
        return FetchDescriptor<C>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to
            },
            sortBy: [SortDescriptor(\.date)]
        )
    }
}

extension MacrosCalorieQuery: CoreQuery where C: PersistentModel {
    var descriptor: FetchDescriptor<C> {
        let (from, to) = (self.calories.from, self.calories.to)
        return FetchDescriptor<C>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to && $0.macros != nil
            },
            sortBy: [SortDescriptor(\.date)]
        )
    }
}
