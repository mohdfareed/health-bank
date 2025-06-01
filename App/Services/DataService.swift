import Foundation
import SwiftData
import SwiftUI

/// A property wrapper that combines SwiftData and HealthKit data queries.
/// Provides a SwiftData @Query-like interface for unified data access.
@MainActor @propertyWrapper struct DataQuery<T>: DynamicProperty
where T: HealthRecord & PersistentModel {
    @Environment(\.healthKit) private var healthKitService
    @Query private var localData: [T]
    @State private var healthKitData: [T] = []

    private let query: any HealthQuery<T>
    private let dateRange: ClosedRange<Date>

    private let filter: Predicate<T>?
    private let sort: [SortDescriptor<T>]
    private let limit: Int?

    @State var isLoading = false

    var wrappedValue: [T] {
        try! (localData + healthKitData)
            .filter(filter ?? #Predicate { _ in true })
            .sorted(using: sort)
    }
    var projectedValue: Self { self }

    init<Q>(
        _ query: Q, from start: Date? = nil, to end: Date? = nil,
        filter: Predicate<T>? = nil, sort: [SortDescriptor<T>]? = nil,
        limit: Int? = nil
    ) where Q: HealthQuery<T> {
        self.query = query
        self.filter = filter
        self.dateRange = .init(from: start, to: end)
        self.sort = sort ?? [.init(\.date, order: .reverse)]
        self.limit = limit

        _localData = .init(
            filter: query.predicate(
                from: dateRange.lowerBound, to: dateRange.upperBound,
                limit: limit
            )
        )
    }

    func refresh() async {
        guard HealthKitService.isAvailable else { return }
        isLoading = true
        defer { isLoading = false }

        healthKitData = await query.fetch(
            from: dateRange.lowerBound, to: dateRange.upperBound, limit: limit,
            store: healthKitService
        ).filter { $0.source != .local }
    }
}

extension ClosedRange<Date> {
    init(from start: Bound?, to end: Bound?) {
        let start = start ?? .distantPast
        let end = end ?? .distantFuture
        self = start...end
    }
}
