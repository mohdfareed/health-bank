import Foundation
import SwiftData

struct CalorieMacros: Codable {
    /// The amount of protein in grams.
    var protein: UInt?
    /// The amount of fat in grams.
    var fat: UInt?
    /// The amount of carbs in grams.
    var carbs: UInt?
}

// MARK: Consumed

/// Entry of consumed calories.
@Model
final class ConsumedCalories {
    /// The date the entry was created.
    var date: Date
    /// The amount of calories consumed.
    var calories: UInt
    /// The calorie macros breakdown.
    var macros: CalorieMacros

    init(_ calories: UInt, macros: CalorieMacros, on date: Date) {
        self.date = date
        self.consumed = calories
        self.macros = macros
    }
}

// MARK: Burned

/// Entry of burned calories.
@Model
final class BurnedCalories {
    /// The date the entry was created.
    var date: Date
    /// The amount of calories burned.
    var calories: UInt
    /// The duration of the activity.
    var duration: TimeInterval?

    init(_ calories: UInt, for duration: TimeInterval? = nil, on date: Date) {
        self.date = date
        self.burned = calories
        self.duration = duration
    }
}
