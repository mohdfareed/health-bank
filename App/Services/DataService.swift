import Foundation
import SwiftData
import SwiftUI

// MARK: Data Query
// ============================================================================

/// A property wrapper that combines SwiftData and HealthKit data queries.
/// Both local and HealthKit data are paginated for memory efficiency.
@MainActor @propertyWrapper
struct DataQuery<T>: DynamicProperty
where T: HealthRecord {
    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.healthKit)
    private var healthKitService

    private let query: any HealthQuery<T>
    private let dateRange: ClosedRange<Date>
    private let pageSize: Int

    @State var isLoading = false
    @State var hasMoreData = true

    @State private var data: [T] = []  // Aggregated data
    @State private var offset: Int = 0  // pagination offset

    var wrappedValue: [T] {
        data.sorted(by: { $0.date > $1.date })
    }
    var projectedValue: Self { self }

    init<Q>(
        _ query: Q,
        from start: Date? = nil, to end: Date? = nil, limit: Int = 50
    ) where Q: HealthQuery<T> {
        self.query = query
        self.dateRange = .init(from: start, to: end)
        self.pageSize = limit
    }
}

// MARK: Data Loading
// ============================================================================

extension DataQuery {
    func reload() async {
        guard !isLoading else { return }

        data = []
        offset = 0
        hasMoreData = true
        await load()
    }

    func load() async {
        guard !isLoading, hasMoreData else { return }
        defer { isLoading = false }
        isLoading = true

        let newData = await loadLocalData() + loadRemoteData()
        data += newData
        hasMoreData = newData.count >= pageSize
    }
}

// MARK: Loading Logic
// ============================================================================

extension DataQuery {
    private func loadRemoteData() async -> [T] {
        guard HealthKitService.isAvailable else { return [] }
        let startDate: Date

        // Calculate start date for cursor-based pagination
        // Use last remote item's date + 1ms to avoid duplicates
        let remoteData = data.filter({ $0.source != .local })
        if let lastItem = remoteData.max(by: { $0.date < $1.date }) {
            startDate = lastItem.date.addingTimeInterval(0.001)
        } else {
            startDate = dateRange.lowerBound
        }

        return await query.fetch(
            from: startDate, to: dateRange.upperBound, limit: pageSize,
            store: healthKitService
        ).filter { $0.source != .local }
    }

    private func loadLocalData() -> [T] {
        var descriptor = query.descriptor(
            from: dateRange.lowerBound, to: dateRange.upperBound
        )
        descriptor.fetchOffset = offset
        descriptor.fetchLimit = pageSize

        do {
            let localData = try modelContext.fetch(descriptor)
            offset += localData.count
            return localData
        } catch {
            AppLogger.new(for: T.Type.self).error(
                "Failed to fetch local data: \(error)"
            )
            return []
        }
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
