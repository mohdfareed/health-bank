import Foundation
import SwiftData

/// A macro-nutrient breakdown of calories.
struct CalorieMacros: Codable {
    /// The amount of protein in grams.
    var protein: Double?
    /// The amount of fat in grams.
    var fat: Double?
    /// The amount of carbs in grams.
    var carbs: Double?
}

// MARK: Consumed

/// Entry of consumed calories.
@Model
final class ConsumedCalories: DataEntry {
    var date: Date
    var source: DataSource

    /// The amount of calories consumed.
    var consumed: UInt
    /// The macro-nutrient breakdown.
    var macros: CalorieMacros

    init(
        _ calories: UInt, with macros: CalorieMacros = CalorieMacros(),
        on date: Date, from: DataSource = .manual
    ) {
        self.date = date
        self.source = source
        self.consumed = calories
        self.macros = macros
    }
}

// MARK: Burned

/// Entry of burned calories.
@Model
final class BurnedCalories: DataEntry {
    var date: Date
    var source: DataSource

    /// The amount of calories burned.
    var burned: UInt
    /// The duration of the activity.
    var duration: TimeInterval?

    init(
        _ calories: UInt, for duration: TimeInterval? = nil,
        on date: Date, from source: DataSource = .manual
    ) {
        self.date = date
        self.source = source
        self.burned = calories
        self.duration = duration
    }
}
