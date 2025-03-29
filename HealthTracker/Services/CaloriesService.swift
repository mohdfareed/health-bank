// import Foundation

// extension ConsumedCalories {
//     static let caloriesUnit = UnitEnergy.kilocalories
//     static let proteinUnit = UnitMass.grams
//     static let fatUnit = UnitMass.grams
//     static let carbsUnit = UnitMass.grams
// }

// extension BurnedCalories {
//     static let caloriesUnit = UnitEnergy.kilocalories
//     static let durationUnit = UnitDuration.seconds
// }

// extension [ConsumedCalories] {
//     /// The consumed calories as data points.
//     var consumedData: [any DataPoint<Date, UInt>] {
//         self.points(x: \.date, y: \.calories)
//     }

//     /// The protein data points.
//     var proteinData: [any DataPoint<Date, UInt>] {
//         self.filter { $0.macros.protein != nil }
//             .points(x: \.date, y: \.macros.protein!)
//     }

//     /// The fat data points.
//     var fatData: [any DataPoint<Date, UInt>] {
//         self.filter { $0.macros.fat != nil }
//             .points(x: \.date, y: \.macros.fat!)
//     }

//     /// The carbs data points.
//     var carbsData: [any DataPoint<Date, UInt>] {
//         self.filter { $0.macros.carbs != nil }
//             .points(x: \.date, y: \.macros.carbs!)
//     }
// }

// extension [BurnedCalories] {
//     /// The consumed calories as negative data points.
//     var consumedData: [any DataPoint<Date, UInt>] {
//         self.points(x: \.date, y: \.calories)
//     }

//     /// The duration of the activities.
//     var durationData: [any DataPoint<Date, TimeInterval>] {
//         self.filter { $0.duration != nil }
//             .points(x: \.date, y: \.duration!)
//     }
// }

// extension ConsumedCalories {
//     /// The total calories from the macros.
//     func calcCalories() -> UInt? {
//         guard let p = self.macros.protein, let f = self.macros.fat, let c = self.macros.carbs else {
//             return nil
//         }
//         return ((p + c) * 4) + (f * 9)
//     }

//     /// The amount of protein in grams from the calories.
//     func calFat() -> Double? {
//         guard let protein = self.macros.protein, let carbs = self.macros.carbs else {
//             return nil
//         }

//         let proteinCalories = protein * 4
//         let carbsCalories = carbs * 4
//         return Double(self.calories - proteinCalories - carbsCalories) / 9
//     }

//     /// The amount of fat in grams from the calories.
//     func calcProtein() -> Double? {
//         guard let fat = self.macros.fat, let carbs = self.macros.carbs else {
//             return nil
//         }

//         let fatCalories = fat * 9
//         let carbsCalories = carbs * 4
//         return Double(self.calories - fatCalories - carbsCalories) / 4
//     }

//     /// The amount of carbs in grams from the calories.
//     func calcCarbs() -> Double? {
//         guard let protein = self.macros.protein, let fat = self.macros.fat else {
//             return nil
//         }

//         let proteinCalories = protein * 4
//         let fatCalories = fat * 9
//         return Double(self.calories - proteinCalories - fatCalories) / 4
//     }
// }
