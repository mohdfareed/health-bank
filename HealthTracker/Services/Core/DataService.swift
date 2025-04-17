import SwiftData
import SwiftUI

// MARK: `SwiftUI` Integration
// ============================================================================

/// A property wrapper that fetches local and remote data. The remote data is
/// initially empty and is populated when the
@MainActor @propertyWrapper
struct RemoteRecordsQuery<M>: DynamicProperty where M: RemoteRecord {
    @Environment(\.remoteContext)
    var context: RemoteContext

    @State private var isInitialized = false
    @State var remoteModels: [M] = []
    @Query var localModels: [M]

    let remoteQuery: M.Query
    let inMemoryQuery: InMemoryQuery<M>

    var wrappedValue: [M] {
        Task { @MainActor in self.initialize() }
        let localModels = self.localModels.filter {
            $0.source == .local  // remove backup of remote data
        }
        return self.filter(localModels + self.remoteModels)
    }
    var projectedValue: Self { self }

    init(_ query: M.Query, inMemory: InMemoryQuery<M> = .init())
    where M.Query: CoreQuery {
        self.remoteQuery = query
        self.inMemoryQuery = inMemory
        self._localModels = .init(
            query.descriptor, animation: self.inMemoryQuery.animation
        )
    }

    /// Refresh the remote data.
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

    /// Initialize the remote records query. This is called once on the first
    /// access to the query to load the initial data.
    private func initialize() {
        guard !self.isInitialized else { return }
        self.refresh()
        self.isInitialized = true
    }

    /// Apply the in-memory query to the models.
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

// MARK: Remote Data Context
// ============================================================================

/// A context for remote data stores.
struct RemoteContext {
    /// The data stores registered with the context.
    let stores: [RemoteStore]

    /// Fetch the data from the remote stores.
    func fetch<M, Q>(_ query: Q) throws -> [M] where Q: RemoteQuery<M> {
        try stores.reduce([]) { $0 + (try $1.fetch(query)) }
            .filter { $0.source != .local }  // de-duplicate
    }

    /// Sync the local data with the remote stores by deleting then saving.
    func sync(_ added: [any DataRecord], _ deleted: [any DataRecord]) throws {
        try deleted.forEach { try self.delete($0) }
        try added.forEach { try self.save($0) }
    }

    /// Save a local data backup to the remote stores.
    private func save(_ model: any DataRecord) throws {
        guard model.source == .local else {
            throw AppError.runtimeError(
                "Can't save non-local data to remote store: \(model)"
            )
        }
        try self.stores.forEach { try $0.save(model) }  // synchronize
    }

    /// Delete a local data backup from the remote stores.
    private func delete(_ model: any DataRecord) throws {
        guard model.source == .local else {
            throw AppError.runtimeError(
                "Can't delete non-local data from remote store: \(model)"
            )
        }
        try self.stores.forEach { try $0.delete(model) }  // synchronize
    }
}

// MARK: Extensions
// ============================================================================

extension EnvironmentValues {
    /// The remote data context for the app.
    @Entry var remoteContext: RemoteContext = RemoteContext(stores: [])
}

extension View {
    /// The remote data context for the app.
    func remoteContext(_ context: RemoteContext) -> some View {
        self.environment(\.remoteContext, context)
    }
}
