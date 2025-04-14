import Combine
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
        var remoteModels: [M] = []
        for store in self.stores {
            let models = try store.fetch(query)
            remoteModels.append(contentsOf: models)
        }
        return remoteModels.filter { $0.source != .local }  // de-duplication
    }

    /// Save a local data backup to the remote stores.
    func save(_ model: any DataRecord) throws {
        guard model.source == .local else {
            throw AppError.runtimeError(
                "Can't save non-local data to remote store: \(model)"
            )
        }
        for store in self.stores {
            try store.save(model)
        }
    }

    /// Delete a local data backup from the remote stores.
    func delete(_ model: any DataRecord) throws {
        guard model.source == .local else {
            throw AppError.runtimeError(
                "Can't delete non-local data from remote store: \(model)"
            )
        }
        for store in self.stores {
            try store.delete(model)
        }
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
