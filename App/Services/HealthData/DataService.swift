import Foundation
import SwiftData
import SwiftUI

// MARK: Data Query
// ============================================================================

/// A property wrapper that paginates HealthKit data queries.
@MainActor @propertyWrapper
struct DataQuery<T>: DynamicProperty
where T: HealthData {
    @Environment(\.healthKit)
    private var healthKitService

    private let query: any HealthQuery<T>
    private let dateRange: ClosedRange<Date>
    private let pageSize: Int

    @State private var items: [T] = []  // Aggregated, paged items
    @State private var cursorDate: Date? = nil  // Pagination cursor

    @State var isLoading = false
    @State var isExhausted = false

    var wrappedValue: [T] {
        items.sorted { $0.date > $1.date }
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

        // Reset pagination
        items = []
        isExhausted = false

        // Start from the top of the date range
        cursorDate = dateRange.lowerBound
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoading, !isExhausted else { return }
        defer { isLoading = false }
        isLoading = true

        // 1) Determine bounds for this page
        let fromDate = cursorDate ?? dateRange.lowerBound
        let toDate = dateRange.upperBound

        // 2) Fetch HealthKit chunk
        var remoteChunk: [T] = []
        if HealthKitService.isAvailable {
            remoteChunk = await query.fetch(
                from: fromDate, to: toDate, limit: pageSize,
                store: healthKitService
            )
            if remoteChunk.count < pageSize {
                isExhausted = true
            }
        }

        // 3) Combine and sort both chunks by date descending
        let chunk = remoteChunk.sorted { $0.date > $1.date }

        // 4) Take only up to `pageSize` items from the combined array
        let page = Array(chunk.prefix(pageSize))
        items.append(contentsOf: page)

        // 5) Update cursorDate to the last item's date minus a small epsilon
        if let last = page.last {
            cursorDate = last.date.addingTimeInterval(-0.001)
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

extension ModelContext {
    /// Erase all data in the context.
    func eraseAll() {
        do {
            for model in HealthDataModel.allCases {
                try erase(model: model)
            }
            try self.delete(model: UserGoals.self)
        } catch {
            print("Failed to erase all data: \(error)")
        }
    }

    private func erase(model: HealthDataModel) throws {
        // TODO: Implement model-specific erasure logic
    }
}
