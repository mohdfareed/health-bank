import Foundation
import SwiftData
import SwiftUI

// MARK: Data Query
// ============================================================================

/// A property wrapper that combines SwiftData and HealthKit data queries.
/// Both local and HealthKit data are paginated for memory efficiency.
@MainActor @propertyWrapper
struct DataQuery<T>: DynamicProperty
where T: HealthDate {
    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.healthKit)
    private var healthKitService

    private let query: any HealthQuery<T>
    private let dateRange: ClosedRange<Date>
    private let pageSize: Int

    @State private var items: [T] = []  // Aggregated, paged items
    @State private var cursorDate: Date? = nil  // Pagination cursor
    @State private var remoteExhausted = false
    @State private var localExhausted = false

    @State var isLoading = false
    var isExhausted: Bool {
        localExhausted && remoteExhausted
    }

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
        localExhausted = false
        remoteExhausted = false

        // Start from the top of the date range
        cursorDate = dateRange.upperBound
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoading, !isExhausted else { return }
        defer { isLoading = false }
        isLoading = true

        // Determine bounds for this page
        let toDate = cursorDate ?? dateRange.upperBound
        let fromDate = dateRange.lowerBound

        // 1) Fetch local chunk
        var descriptor = query.descriptor(from: fromDate, to: toDate)
        descriptor.fetchLimit = pageSize
        var localChunk: [T] = []
        do {
            localChunk = try modelContext.fetch(descriptor)
            if localChunk.count < pageSize {
                localExhausted = true
            }
        } catch {
            localExhausted = true
        }

        // 2) Fetch HealthKit chunk
        var remoteChunk: [T] = []
        if HealthKitService.isAvailable, !remoteExhausted {
            let hkEnd = toDate.addingTimeInterval(-0.001)
            remoteChunk = await query.fetch(
                from: fromDate, to: hkEnd, limit: pageSize,
                store: healthKitService
            ).filter { $0.source != .local }
            if remoteChunk.count < pageSize {
                remoteExhausted = true
            }
        }

        // 3) Combine and sort both chunks by date descending
        let combined = (localChunk + remoteChunk).sorted { $0.date > $1.date }

        // 4) Take only up to `pageSize` items from the combined array
        let pageToShow = Array(combined.prefix(pageSize))
        items.append(contentsOf: pageToShow)

        // 5) Update cursorDate to the last item's date minus a small epsilon
        if let last = pageToShow.last {
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
        switch model {
        case .calorie:
            try self.delete(model: model.dataType as! DietaryCalorie.Type)
        case .activity:
            try self.delete(model: model.dataType as! ActiveEnergy.Type)
        case .resting:
            try self.delete(model: model.dataType as! RestingEnergy.Type)
        case .weight:
            try self.delete(model: model.dataType as! Weight.Type)
        }
    }
}
