import Foundation
import SwiftData

/// The user's daily goals.
@Model final class UserGoals: Singleton {
    var date: Date = Date()

    // calories
    var calories: Double? = 2000  // consumed
    var macros: CalorieMacros? = nil

    // activity
    var burnedCalories: Double? = nil  // burned
    var activity: TimeInterval? = nil  // minutes

    // weight
    var weight: Double? = 70  // kg

    // singleton
    @Attribute(.unique)
    var singletonID = UUID()
    required init() {}
}
