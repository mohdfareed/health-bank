import Foundation
import SwiftData

/// The user's daily goals.
@Model final class Goals: Singleton {
    var date: Date = Date()

    // calories
    var calories: Double? = 2000  // consumed
    var macros: CalorieMacros = CalorieMacros(
        p: 120, f: 60, c: 245  // grams
    )

    // activity
    var burnedCalories: Double? = 350  // burned
    var activity: TimeInterval? = 30  // minutes

    // weight
    var weight: Double? = 70  // kg

    // singleton
    @Attribute(.unique)
    var singletonID = UUID()
    required init() {}
}
