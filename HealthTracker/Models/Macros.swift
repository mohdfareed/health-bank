import Foundation
import SwiftData

/// The proteins of a calories entry.
@Model final class CalorieProteins: DataRecord {
    var id: UUID = UUID()
    var source: DataSource

    /// The date the record was created.
    var date: Date
    /// The proteins of the calories.
    var protein: Double

    init(_ protein: Double, on date: Date, from source: DataSource) {
        self.source = source
        self.date = date
        self.protein = protein
    }
}

/// The fat of the calories.
@Model final class CalorieFat: DataRecord {
    var id: UUID = UUID()
    var source: DataSource

    /// The date the record was created.
    var date: Date
    /// The fat of the calories.
    var fat: Double

    init(_ fat: Double, on date: Date, from source: DataSource) {
        self.source = source
        self.date = date
        self.fat = fat
    }
}

/// The carbohydrates of the calories.
@Model final class CalorieCarbs: DataRecord {
    var id: UUID = UUID()
    var source: DataSource

    /// The date the record was created.
    var date: Date
    /// The carbs of the calories.
    var carbs: Double

    init(_ carbs: Double, on date: Date, from source: DataSource) {
        self.source = source
        self.date = date
        self.carbs = carbs
    }
}
