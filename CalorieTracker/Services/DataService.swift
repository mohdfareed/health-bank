import Foundation
import OSLog
import SwiftData

/// Budget data entry service.
struct DataService {
    internal let logger = Logger(for: DataService.self)
    private let context: ModelContext

    init(_ context: ModelContext) {
        self.context = context
        self.logger.debug("Data entry service initialized.")
    }

    /// Create the fetch descriptor for data entries.
    /// - Parameter startDate: The start date of the range.
    /// - Parameter endDate: The end date of the range.
    /// - Returns: The entries query.
    static func fetch<T: DataEntry & PersistentModel>(
        over interval: DateInterval
    ) throws -> FetchDescriptor<T> {
        let entries = FetchDescriptor<T>(
            predicate: #Predicate { $0.date >= interval.start && $0.date < interval.end },
            sortBy: [
                .init(\.date)
            ]
        )
        return entries
    }

    /// Get the entries within a given date range.
    /// - Parameter startDate: The start date of the range.
    /// - Parameter endDate: The end date of the range.
    func get<T: DataEntry & PersistentModel>(over interval: DateInterval) throws -> [T] {
        self.logger.debug("Fetching entries in date interval: \(interval)")
        let entries: FetchDescriptor<T> = try DataService.fetch(over: interval)

        do {
            let results: [T] = try self.context.fetch(entries)
            self.logger.debug("Fetched \(results.count) entries.")
            return results
        } catch {
            throw DatabaseError.queryError(
                "Failed to fetch entries of type '\(T.self)' in date interval: \(interval)",
                dbError: error
            )
        }
    }

    /// Log a new data entry.
    /// - Parameter entry: The entry to log.
    func create<T: DataEntry & PersistentModel>(_ entry: T) {
        self.logger.debug("Creating entry: \(entry)")
        self.context.insert(entry)
    }

    /// Remove a data entry.
    /// - Parameter entry: The entry to remove.
    func remove<T: DataEntry & PersistentModel>(_ entry: T) {
        self.logger.debug("Removing entry: \(entry)")
        self.context.delete(entry)
    }

    /// Update a data entry.
    /// - Parameter entry: The entry to update.
    func update<T: DataEntry & PersistentModel>(_ entry: T) {
        self.logger.debug("Updating entry: \(entry)")
        if let existing = self.context.model(for: entry.id) as? T {
            self.context.delete(existing)
        }
        self.context.insert(entry)
    }
}
