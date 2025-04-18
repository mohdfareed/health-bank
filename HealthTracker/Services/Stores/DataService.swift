import SwiftData
import SwiftUI

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
struct DataQuery<M>: DynamicProperty where M: DataRecord {
    @Environment(\.remoteContext)
    var context: RemoteContext

    @State private var isInitialized = false
    @State var remoteModels: [M] = []
    @Query var localModels: [M]

    let remoteQuery: any RemoteQuery<M>
    let inMemoryQuery: InMemoryQuery<M>

    var wrappedValue: [M] {
        Task { @MainActor in self.initialize() }
        let localModels = self.localModels.filter {
            $0.source == .local  // remove backup of remote data
        }
        return self.filter(localModels + self.remoteModels)
    }
    var projectedValue: Self { self }

    init<Q>(_ query: Q, inMemory: InMemoryQuery<M> = .init())
    where Q: CoreQuery, Q.Model == M {
        self.remoteQuery = query
        self.inMemoryQuery = inMemory
        self._localModels = Query(
            query.descriptor, animation: self.inMemoryQuery.animation
        )
    }

    /// Refresh the remote data.
    func refresh() {
        self.fetch { models in
            withAnimation(self.inMemoryQuery.animation) {
                self.remoteModels = models
            }
        }
    }

    /// Initialize the remote records query. This is called once on the first
    /// access to the query to load the initial data.
    private func initialize() {
        guard !self.isInitialized else { return }
        self.refresh()
        self.isInitialized = true
    }

    /// Filter the in-memory data using the in-memory query.
    private func filter(_ models: [M]) -> [M] {
        do {
            return try (models).filter {
                (try self.inMemoryQuery.predicate?.evaluate($0)) ?? true
            }
        } catch {
            AppLogger.new(for: InMemoryQuery<M>.self).error(
                "Failed to filter data: \(error)"
            )
        }
    }

    /// Fetch the data from the local context.
    private func fetch(_ callback: @escaping ([M]) -> Void) {
        do {
            callback(try self.context.fetch(self.remoteQuery))
        } catch {
            AppLogger.new(for: InMemoryQuery<M>.self).error(
                "Failed to fetch data: \(error)"
            )
        }
    }
}
extension Query { typealias Data = DataQuery }

extension InMemoryQuery {
    /// Apply the in-memory query to the models.
    func filter(_ models: [Model]) throws -> [Model] {
        var models = try (models).filter {
            (try self.predicate?.evaluate($0)) ?? true
        }

        models = models.filter {
            if self.sources.isEmpty { return true }
            return self.sources.contains($0.source)
        }

        self.sortOrder.forEach { models.sort(using: $0) }
        models = Array(models.dropFirst(self.offset))
        models = Array(models.prefix(self.limit ?? models.count))
        return models
    }
}
