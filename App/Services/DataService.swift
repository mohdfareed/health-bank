import Foundation
import SwiftData
import SwiftUI

/// Projection for DataQuery providing loading states and pagination controls
@MainActor
struct DataQueryProjection<T> where T: HealthRecord & PersistentModel {
    let isLoading: Bool
    let isLoadingMore: Bool
    let hasMoreData: Bool
    let refresh: () async -> Void
    let loadMore: () async -> Void
}

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

    // Pagination state
    @State private var pageSize: Int
    @State private var currentPage: Int = 0
    @State private var hasMoreData: Bool = true
    @State private var allLoadedData: [T] = []

    @State var isLoading = false
    @State var isLoadingMore = false

    var wrappedValue: [T] {
        do {
            let combinedData = try (localData + allLoadedData)
                .filter(filter ?? #Predicate { _ in true })
                .sorted(using: sort)

            // Apply pagination limit to combined data
            let endIndex = min((currentPage + 1) * pageSize, combinedData.count)
            return Array(combinedData.prefix(endIndex))
        } catch {
            // Fallback to basic combination if filtering fails
            let combinedData = (localData + allLoadedData).sorted(using: sort)
            let endIndex = min((currentPage + 1) * pageSize, combinedData.count)
            return Array(combinedData.prefix(endIndex))
        }
    }

    var projectedValue: DataQueryProjection<T> {
        DataQueryProjection(
            isLoading: isLoading,
            isLoadingMore: isLoadingMore,
            hasMoreData: hasMoreData,
            refresh: refresh,
            loadMore: loadMore
        )
    }

    init<Q>(
        _ query: Q, from start: Date? = nil, to end: Date? = nil,
        filter: Predicate<T>? = nil, sort: [SortDescriptor<T>]? = nil,
        pageSize: Int = 50
    ) where Q: HealthQuery<T> {
        self.query = query
        self.filter = filter
        self.dateRange = .init(from: start, to: end)
        self.sort = sort ?? [.init(\.date, order: .reverse)]
        self.pageSize = pageSize

        _localData = .init(
            filter: query.predicate(
                from: dateRange.lowerBound, to: dateRange.upperBound,
                limit: nil
            )
        )
    }

    func refresh() async {
        guard HealthKitService.isAvailable else { return }
        isLoading = true
        currentPage = 0
        allLoadedData = []
        hasMoreData = true
        defer { isLoading = false }

        let newData = await query.fetch(
            from: dateRange.lowerBound, to: dateRange.upperBound,
            limit: pageSize,
            store: healthKitService
        ).filter { $0.source != .local }

        allLoadedData = newData
        hasMoreData = newData.count >= pageSize
    }

    func loadMore() async {
        guard
            !isLoadingMore && hasMoreData && HealthKitService.isAvailable
        else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        // Calculate date range for next page based on last loaded item
        let lastDate = allLoadedData.last?.date ?? dateRange.upperBound
        let newData = await query.fetch(
            from: dateRange.lowerBound, to: lastDate,
            limit: pageSize,
            store: healthKitService
        ).filter { newItem in
            newItem.source != .local
                && !allLoadedData.contains { $0.id == newItem.id }
        }

        if newData.isEmpty || newData.count < pageSize {
            hasMoreData = false
        } else {
            allLoadedData.append(contentsOf: newData)
            currentPage += 1
        }
    }
}

extension ClosedRange<Date> {
    init(from start: Bound?, to end: Bound?) {
        let start = start ?? .distantPast
        let end = end ?? .distantFuture
        self = start...end
    }
}
