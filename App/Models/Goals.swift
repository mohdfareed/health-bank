import Foundation
import SwiftData

/// The user's daily goals.
@Model final class UserGoals: Singleton {
    var date: Date = Date()

    // calories
    var calories: Double? = 2000
    var macros: CalorieMacros? = nil

    // activity
    var burnedCalories: Double? = 500
    var activity: TimeInterval? = 30

    // weight
    var weight: Double? = 70

    // singleton
    var id: UUID
    required init(id: ID = .init()) { self.id = id }
}
