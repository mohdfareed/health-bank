import Foundation
import SwiftData

// MARK: Calories Consumed
// ============================================================================

extension CalorieConsumed {
    static let caloriesUnit = UnitEnergy.kilocalories
    static let proteinUnit = UnitMass.grams
    static let fatUnit = UnitMass.grams
    static let carbsUnit = UnitMass.grams
}

extension CalorieConsumed: RemoteRecord {
    typealias Model = Query
    struct Query: RemoteQuery {
        typealias Model = CalorieConsumed
        let from: Date
        let to: Date
        let withMacros: Bool
    }
}

extension CalorieConsumed.Query: CoreQuery {
    var descriptor: FetchDescriptor<CalorieConsumed> {
        let (from, to) = (self.from, self.to)

        return FetchDescriptor<CalorieConsumed>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to
            },
            sortBy: [SortDescriptor(\.date)]
        )
    }
}

// MARK: Calorie Burned
// ============================================================================

extension CalorieBurned {
    static let caloriesUnit = UnitEnergy.kilocalories
    static let durationUnit = UnitDuration.seconds
}

extension CalorieBurned: RemoteRecord {
    typealias Model = Query
    struct Query: RemoteQuery {
        typealias Model = CalorieBurned
        let from: Date
        let to: Date
    }
}

extension CalorieBurned.Query: CoreQuery {
    var descriptor: FetchDescriptor<CalorieBurned> {
        let (from, to) = (self.from, self.to)
        return FetchDescriptor<CalorieBurned>(
            predicate: #Predicate {
                $0.date >= from && $0.date <= to
            },
            sortBy: [SortDescriptor(\.date)]
        )
    }
}

// MARK: Calorie Units
// ============================================================================

enum CalorieUnit: DataUnit {
    typealias DimensionType = UnitEnergy
    static let id: String = "CalorieUnit"
    case calories, joules
    var unit: DimensionType {
        switch self {
        case .calories: .kilocalories
        case .joules: .kilojoules
        }
    }
    init() { self = .calories }
}

enum MacrosUnit: DataUnit {
    typealias DimensionType = UnitMass
    static let id: String = "MacrosUnit"
    case grams
    var unit: DimensionType {
        switch self {
        case .grams: .grams
        }
    }
    init() { self = .grams }
}

// MARK: Calorie Breakdown
// ============================================================================

extension CalorieConsumed {
    /// The total calories from the macros.
    func calcCalories() -> Double? {
        guard
            let p = self.macros?.protein,
            let f = self.macros?.fat,
            let c = self.macros?.carbs
        else { return nil }
        return ((p + c) * 4) + (f * 9)
    }

    /// The amount of protein in grams from the calories.
    func calFat() -> Double? {
        guard
            let protein = self.macros?.protein,
            let carbs = self.macros?.carbs
        else { return nil }

        let proteinCalories = protein * 4
        let carbsCalories = carbs * 4
        return Double(self.calories - proteinCalories - carbsCalories) / 9
    }

    /// The amount of fat in grams from the calories.
    func calcProtein() -> Double? {
        guard
            let fat = self.macros?.fat,
            let carbs = self.macros?.carbs
        else { return nil }

        let fatCalories = fat * 9
        let carbsCalories = carbs * 4
        return Double(self.calories - fatCalories - carbsCalories) / 4
    }

    /// The amount of carbs in grams from the calories.
    func calcCarbs() -> Double? {
        guard
            let protein = self.macros?.protein,
            let fat = self.macros?.fat
        else { return nil }

        let proteinCalories = protein * 4
        let fatCalories = fat * 9
        return Double(self.calories - proteinCalories - fatCalories) / 4
    }
}
