import Foundation
import SwiftData
import SwiftUI

/// Projection for DataQuery providing simple loading states and pagination controls
@MainActor
struct DataQueryProjection<T> where T: HealthRecord {
    let isRefreshing: Bool
    let isLoading: Bool
    let refresh: () async -> Void
    let loadNext: () async -> Void
}

// MARK: Data Query
// ============================================================================

/// A property wrapper that combines SwiftData and HealthKit data queries.
/// Both local and HealthKit data are paginated for memory efficiency.
@MainActor @propertyWrapper
struct DataQuery<T>: DynamicProperty
where T: HealthRecord {
    @Environment(\.healthKit) private var healthKitService
    @Query private var localData: [T]

    @Binding
    private var page: Int?
    private let pageSize: Int
    private let query: any HealthQuery<T>
    private let dateRange: ClosedRange<Date>

    @State private var remoteData: [T] = []
    @State private var isRefreshing = false
    @State private var isLoading = false

    var wrappedValue: [T] {
        (localData + remoteData).sorted(by: { $0.date > $1.date })
    }

    var projectedValue: DataQueryProjection<T> {
        DataQueryProjection(
            isRefreshing: isRefreshing,
            isLoading: isLoading,
            refresh: refresh,
            loadNext: loadNext
        )
    }

    init<Q>(
        _ query: Q, from start: Date? = nil, to end: Date? = nil,
        pageSize: Int = 50, page: Binding<Int?> = .constant(nil)
    ) where Q: HealthQuery<T> {
        self.query = query
        self.dateRange = .init(from: start, to: end)
        self.pageSize = pageSize
        self._page = page

        var descriptor = FetchDescriptor<T>(
            predicate: query.predicate(
                from: dateRange.lowerBound,
                to: dateRange.upperBound,
            ),
        )
        descriptor.fetchLimit = pageSize
        descriptor.fetchOffset = 0
        _localData = Query(descriptor, animation: .default)
    }

}

// MARK: Remote Data
// ============================================================================

extension DataQuery {
    func refresh() async {
        guard !isRefreshing else { return }
        defer { isRefreshing = false }

        isRefreshing = true
        remoteData = []
        page = 0
        remoteData = await loadRemoteData()
    }

    func loadNext() async {
        guard !isLoading && !isRefreshing else { return }
        defer { isLoading = false }

        isLoading = true
        guard let currentPage = page else { return }
        page = currentPage + 1
        remoteData = await loadRemoteData()
    }

    private func loadRemoteData() async -> [T] {
        guard HealthKitService.isAvailable else { return [] }
        return await query.fetch(
            from: dateRange.lowerBound, to: dateRange.upperBound,
            limit: (page ?? 0 * pageSize) + pageSize,
            store: healthKitService
        ).filter { $0.source != .local }
    }
}

// MARK: Extensions
// ============================================================================

extension ClosedRange<Date> {
    init(from start: Bound?, to end: Bound?) {
        let start = start ?? .distantPast
        let end = end ?? .distantFuture
        self = start...end
    }
}
