import Foundation
import SwiftData
import SwiftUI

/// A property wrapper that combines SwiftData and HealthKit data queries.
/// Provides a SwiftData @Query-like interface for unified data access.
@MainActor @propertyWrapper
struct UnifiedQuery<T: DataRecord & PersistentModel>: DynamicProperty {
    @Environment(\.healthKit) private var healthKitService
    @Query private var localData: [T]
    @State private var healthKitData: [T] = []

    private let query: any DataQuery<T>
    private let filter: Predicate<T>?
    private let sort: [SortDescriptor<T>]

    @State var isLoading = false

    var wrappedValue: [T] {
        let remote = healthKitData.filter { $0.source != .local }
        let combined = localData + remote

        return
            combined
            .filter {
                do {
                    return try filter?.evaluate($0) ?? true
                } catch {
                    AppLogger.new(for: UnifiedQuery.self)
                        .error("Failed to evaluate filter: \(error)")
                    return true  // Include all if filter fails
                }
            }
            .sorted(using: sort)
    }
    var projectedValue: UnifiedQuery<T> { self }

    init(
        _ query: any DataQuery<T>,
        filter: Predicate<T>? = nil, sort: [SortDescriptor<T>]? = nil
    ) {
        self.query = query
        self.filter = filter
        self.sort = sort ?? [.init(\.date, order: .reverse)]
        _localData = Query(filter: query.predicate())
    }

    func refresh() async { await loadRemoteDate() }

    private func loadRemoteDate() async {
        guard HealthKitService.isAvailable else { return }
        isLoading = true
        defer { isLoading = false }
        healthKitData = query.remote(store: healthKitService)
    }
}
