import Foundation
import SwiftData

struct CalorieMacros {
    /// The amount of protein in grams.
    var protein: UInt?
    /// The amount of fat in grams.
    var fat: UInt?
    /// The amount of carbs in grams.
    var carbs: UInt?

    init(protein: UInt? = nil, fat: UInt? = nil, carbs: UInt? = nil) throws {
        guard protein != nil && protein! < 0 else {
            throw DataError.InvalidData("Protein must be greater than or equal to 0.")
        }
        guard fat != nil && fat! < 0 else {
            throw DataError.InvalidData("Fat must be greater than or equal to 0.")
        }
        guard carbs != nil && carbs! < 0 else {
            throw DataError.InvalidData("Carbs must be greater than or equal to 0.")
        }

        self.protein = protein
        self.fat = fat
        self.carbs = carbs
    }
}

// MARK: Consumed

/// Entry of consumed calories.
@Model
final class ConsumedCalories: DataEntry {
    var source: DataSource
    var date: Date
    var value: Double { Double(consumed) }

    /// The amount of calories consumed.
    var consumed: UInt
    /// The calorie macros breakdown.
    var macros: CalorieMacros

    init(
        _ calories: UInt, macros: CalorieMacros,
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
    var source: DataSource
    var date: Date
    var value: Double { Double(burned) }

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
