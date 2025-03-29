import Foundation
import SwiftData

/// The proteins of a calories entry.
@Model
final class CalorieProteins: HistoricalDataModel {
    var source: DataSource
    var date: Date
    /// The proteins of the calories.
    var protein: Double

    init(
        _ protein: Double, on date: Date? = Date(),
        from source: DataSource? = .CoreData
    ) {
        self.source = source ?? self.source
        self.date = date ?? self.date
        self.protein = protein
    }
}

/// The fat of the calories.
@Model
final class CalorieFat: HistoricalDataModel {
    var source: DataSource
    var date: Date
    /// The fat of the calories.
    var fat: Double

    init(
        _ fat: Double, on date: Date? = Date(),
        from source: DataSource? = .CoreData
    ) {
        self.source = source ?? self.source
        self.date = date ?? self.date
        self.fat = fat
    }
}

/// The carbohydrates of the calories.
@Model
final class CalorieCarbs: HistoricalDataModel {
    var source: DataSource
    var date: Date
    /// The carbs of the calories.
    var carbs: Double

    init(
        _ carbs: Double, on date: Date? = Date(),
        from source: DataSource? = .CoreData
    ) {
        self.source = source ?? self.source
        self.date = date ?? self.date
        self.carbs = carbs
    }
}
