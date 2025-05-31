import Foundation
import SwiftData
import SwiftUI

/// A property wrapper that combines SwiftData and HealthKit data queries.
/// Provides a SwiftData @Query-like interface for unified data access.
@MainActor @propertyWrapper
// struct UnifiedQuery<T, Q>: DynamicProperty
// where T: HealthRecord & PersistentModel, Q: HealthQuery<T> {
struct UnifiedQuery<T>: DynamicProperty
where T: HealthQuery, T.Record: HealthRecord & PersistentModel {
    @Environment(\.healthKit) private var healthKitService
    @Query private var localData: [T.Record]
    @State private var healthKitData: [T.Record] = []

    private let query: T
    private let dateRange: ClosedRange<Date>

    private let filter: Predicate<T.Record>?
    private let sort: [SortDescriptor<T.Record>]

    @State var isLoading = false

    var wrappedValue: [T.Record] {
        try! (localData + healthKitData)
            .filter(filter ?? #Predicate { _ in true })
            .sorted(using: sort)
    }
    var projectedValue: Self { self }

    init(
        _ query: T, from start: Date? = nil, to end: Date? = nil,
        filter: Predicate<T.Record>? = nil,
        sort: [SortDescriptor<T.Record>]? = nil
    ) {
        self.query = query
        self.filter = filter
        self.dateRange = .init(from: start, to: end)
        self.sort = sort ?? [.init(\.date, order: .reverse)]
        _localData = localQuery()
    }

    func refresh() async { await loadDate() }

    private func loadDate() async {
        guard HealthKitService.isAvailable else { return }
        isLoading = true
        defer { isLoading = false }

        healthKitData = query.fetch(
            from: dateRange.lowerBound, to: dateRange.upperBound,
            store: healthKitService
        ).filter { $0.source != .local }
    }

    private func localQuery() -> Query<T.Record, [T.Record]> {
        let (from, to) = (dateRange.lowerBound, dateRange.upperBound)
        return .init(
            filter: #Predicate {
                from <= $0.date && $0.date <= to
            }
        )
    }
}

extension ClosedRange<Date> {
    init(from start: Bound?, to end: Bound?) {
        let start = start ?? .distantPast
        let end = end ?? .distantFuture
        self = start...end
    }
}
