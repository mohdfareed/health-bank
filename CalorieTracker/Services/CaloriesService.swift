import Foundation
import SwiftData

/// Calorie entry service that manages calorie entries.
struct CaloriesService {
    private let context: ModelContext

    init(_ context: ModelContext) {
        self.context = context
    }

    /// Get the entries within a given date range.
    /// - Parameters:
    ///   - startDate: The start date of the range.
    ///   - endDate: The end date of the range.
    func get(from startDate: Date, to endDate: Date) throws -> [CalorieEntry] {
        let entries = FetchDescriptor<CalorieEntry>(
            predicate: #Predicate { $0.date >= startDate && $0.date < endDate },
            sortBy: [
                .init(\.date)
            ]
        )

        do {
            let results: [CalorieEntry] = try self.context.fetch(entries)
            return results
        } catch {
            throw CaloriesError.databaseError(dbError: error)
        }
    }

    /// Get the entries for a given day.
    /// - Parameter date: The reference date.
    /// - Returns: The entries for the day.
    func get(for date: Date) throws -> [CalorieEntry] {
        let start = Calendar.current.startOfDay(for: date)
        let end = start.adding(days: 1)
        let entries = try self.get(from: start, to: end)
        return entries
    }

    /// Log a new calorie entry.
    /// - Parameter entry: The entry to log.
    func create(_ entry: CalorieEntry) {
        self.context.insert(entry)
    }

    /// Remove a calorie entry.
    /// - Parameter entry: The entry to remove.
    func remove(_ entry: CalorieEntry) {
        self.context.delete(entry)
    }

    /// Update a calorie entry.
    /// - Parameter entry: The entry to update.
    func update(_ entry: CalorieEntry) {
        if let existing = self.context.model(for: entry.id) as? CalorieEntry {
            self.context.delete(existing)
        }
        self.context.insert(entry)
    }
}

// MARK: Extensions

extension Array where Element == CalorieEntry {
    /// The total calories consumed or burned.
    /// - Returns: The total number of calories.
    var totalCalories: Int {
        let total = self.reduce(0) { $0 + $1.calories }
        return total
    }
}
