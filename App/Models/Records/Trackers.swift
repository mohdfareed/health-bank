import Foundation
import SwiftData

// MARK: Budgets
// ============================================================================

/// The user's daily budgets.
@Model final class Budgets: Singleton {
    var date: Date = Date()

    // calories
    var calories: Double? = 2000  // kcal
    var macros: CalorieMacros = CalorieMacros(
        p: 120, f: 60, c: 245  // grams
    )

    // singleton
    @Attribute(.unique)
    var singletonID = UUID()
    required init() {}
}

// MARK: Goals
// ============================================================================

/// The user's daily goals.
@Model final class Goals: Singleton {
    var date: Date = Date()

    // calories
    var calories: Double? = nil  // burned
    var macros: CalorieMacros = CalorieMacros(
        p: 120, f: 60, c: 245  // grams
    )

    // activity
    var activity: TimeInterval? = nil  // minutes

    // weight
    var weight: Double? = nil  // kg

    // singleton
    @Attribute(.unique)
    var singletonID = UUID()
    required init() {}
}
