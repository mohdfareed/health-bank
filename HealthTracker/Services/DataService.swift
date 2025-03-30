import Combine
import SwiftData
import SwiftUI

class DataContainer {
    internal let logger = AppLogger.new(for: DataContainer.self)
    let container: ModelContainer
    let stores: [any Store]

    @MainActor var mainContext: ModelContext { self.container.mainContext }

    private lazy var subscription: any Cancellable = {
        NotificationCenter.default.publisher(
            for: ModelContext.willSave
        )
        .map({ $0.object as? ModelContext })
        .sink { [weak self] context in
            guard let context = context else { return }
            for store in self?.stores ?? [] {
                store.sync(with: context)
            }
        }
    }()

    init(for types: any DataModel.Type..., stores: [any Store] = []) {
        self.container = try! ModelContainer(
            for: Schema(types),
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        self.stores = stores
        self.logger.debug("App data container initialized.")
    }

    func load<M>(
        _ descriptor: FetchDescriptor<M>, context: ModelContext
    ) where M: DataModel {
        self.stores.forEach {
            let store = $0 as! any Store<M>
            store.load(descriptor, into: context)
        }
    }

    deinit {
        self.subscription.cancel()
        self.logger.debug("App data container de-initialized.")
    }
}

extension Store {
    internal func load<M>(
        _ descriptor: FetchDescriptor<M>, into context: ModelContext
    ) where M == Self.Model {
        do {
            let results = try context.fetch(descriptor)
            for model in results {
                context.insert(model)
            }
        } catch {
            AppLogger.new(for: Self.self).error(
                "Failed to fetch model \(type(of: M.self)): \(error)"
            )
        }
    }

    internal func sync(with context: ModelContext) {
        for model in context.insertedModelsArray + context.changedModelsArray {
            guard let model = supported(model) else { continue }
            do {
                try self.save(model)
            } catch {
                AppLogger.new(for: Self.self).error(
                    "Failed to save model \(type(of: model)): \(error)"
                )

            }
        }

        for model in context.deletedModelsArray {
            guard let model = supported(model) else { continue }
            do {
                try self.delete(model)
            } catch {
                AppLogger.new(for: Self.self).error(
                    "Failed to delete model \(type(of: model)): \(error)"
                )
            }
        }
    }

    private func supported(_ model: Any) -> Model? {
        guard let model = model as? Model else { return nil }
        return self.sources.contains(model.source) ? model : nil
    }
}

extension EnvironmentValues {
    @Entry var dataContext = ModelContext(DataContainer().container)
}

// MARK: Wrappers

// @MainActor @propertyWrapper
// struct StoreQuery<Model: DataModel>: DynamicProperty {
//     @Environment(\.modelContext) private var dataContext
//     @Query private var coreModels: [Model]
//     init() {
//         var descriptor = FetchDescriptor<Model>()
//         Environment)
//     }
// }

// @MainActor @propertyWrapper
// struct DataQuery<Model: DataModel>: DynamicProperty {
//     @Environment(\.modelContext) private var coreContext
//     @Environment(\.dataContext) private var dataContext
//     @Query private var coreModels: [Model]
//     // @Query private var dataModels: [Model]

//     init() {
//         var descriptor = FetchDescriptor<Model>()
//         descriptor.fetchLimit = 1
//         self._coreModels = Query(descriptor)
//         // self._dataModels = Query(descriptor)
//     }

//     var wrappedValue: [Model] {
//         self.coreModels + self.dataModels
//     }
// }

// MARK: Errors

enum DatabaseError: Error {
    case InitializationError(String, Error? = nil)
    case readError(String, Error? = nil)
    case writeError(String, Error? = nil)
}
