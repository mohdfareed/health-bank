import SwiftData
import SwiftUI

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
    func sync(
        added: [any DataRecord],
        deleted: [any DataRecord],
        modified: [any DataRecord] = []
    ) throws {
        try (deleted + modified).forEach { try self.delete($0) }
        try (added + modified).forEach { try self.save($0) }
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
