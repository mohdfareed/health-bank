import Combine
import SwiftData
import SwiftUI

// MARK: `SwiftData` Integration
// ============================================================================

protocol CoreQuery: RemoteQuery where Model: PersistentModel {
    /// The local data store query descriptor.
    var descriptor: FetchDescriptor<Model> { get }
}

/// The in-memory filter to apply to data from remote sources.
struct InMemoryQuery<Model: DataRecord> {
    /// The data sources of the data. Query all sources if empty.
    var sources: [DataSource] = []
    /// The predicate to filter the data.
    var predicate: Predicate<Model>? = nil
    /// The sort order of the data.
    var sortOrder: [SortDescriptor<Model>] = []
    /// The limit of the data.
    var limit: Int? = nil
    /// The offset of the data.
    var offset: Int = 0
    /// The animation to apply to the data.
    var animation: Animation = .default
}

// MARK: `SwiftUI` Integration
// ============================================================================

/// A property wrapper that fetches local and remote data. The remote data is
/// initially empty and is populated when the
@MainActor @propertyWrapper
struct RemoteRecordsQuery<M>: DynamicProperty where M: RemoteRecord {
    @Environment(\.remoteContext) var context
    @State var remoteModels: [M] = []
    @Query var localModels: [M]

    @State private var isInitialized = false
    let remoteQuery: M.Query
    let inMemoryQuery: InMemoryQuery<M>

    var wrappedValue: [M] {
        Task { @MainActor in self.initialize() }
        return self.filter(self.localModels + self.remoteModels)
    }
    var projectedValue: Self { self }

    @MainActor init(_ query: M.Query, inMemory: InMemoryQuery<M> = .init())
    where M.Query: CoreQuery {
        self.remoteQuery = query
        self.inMemoryQuery = inMemory
        self._localModels = .init(
            query.descriptor, animation: self.inMemoryQuery.animation
        )
    }

    func refresh() {
        do {
            let models = try self.context.fetch(self.remoteQuery)
            withAnimation(self.inMemoryQuery.animation) {
                self.remoteModels = models
            }
        } catch {
            AppLogger.new(for: M.Query.self).error(
                "Failed to fetch data: \(error)"
            )
        }
    }

    private func initialize() {
        guard !self.isInitialized else { return }
        self.refresh()
        self.isInitialized = true
    }

    private func filter(_ models: [M]) -> [M] {
        var models = models

        do {
            models = try (models).filter {
                (try self.inMemoryQuery.predicate?.evaluate($0)) ?? true
            }
        } catch {
            AppLogger.new(for: M.Query.self).error(
                "Failed to filter data: \(error)"
            )
            return []
        }

        models = models.filter {
            if self.inMemoryQuery.sources.isEmpty { return true }
            return self.inMemoryQuery.sources.contains($0.source)
        }

        self.inMemoryQuery.sortOrder.forEach { models.sort(using: $0) }
        models = Array(models.dropFirst(self.inMemoryQuery.offset))
        models = Array(models.prefix(self.inMemoryQuery.limit ?? models.count))
        return models
    }
}
extension Query { typealias Remote = RemoteRecordsQuery }
