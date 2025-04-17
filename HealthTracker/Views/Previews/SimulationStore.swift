import HealthKit
import SwiftData
import SwiftUI

protocol SimulationModel: RemoteRecord { init() }

protocol SimulationQuery<Model>: RemoteQuery where Model: SimulationModel {
    var predicate: Predicate<Model> { get }
}

class SimulatedStore: RemoteStore {
    let logger = AppLogger.new(for: SimulatedStore.self)
    var models: [any SimulationModel]

    init(using models: [any SimulationModel] = []) {
        models.forEach { $0.source = .simulation }
        self.models = models
    }

    func fetch<M, Q>(_ query: Q) throws -> [M]
    where M == Q.Model, Q: RemoteQuery {
        guard let query = query as? any SimulationQuery<M> else {
            return []
        }
        var models = self.models.compactMap { $0 as? M }
        models = try models.filter { try query.predicate.evaluate($0) }
        self.logger.info(
            "Fetched \(models.count) simulation models of type \(M.self)"
        )
        print("Fetched simulation models: \(models)")
        return models
    }

    func save(_ model: any DataRecord) throws {
        guard let model = model as? any SimulationModel else {
            return
        }
        self.models.append(model)
        self.logger.info(
            "Saved simulation model \(type(of: model))"
        )
        print("Saved simulation model \(model)")
    }

    func delete(_ model: any DataRecord) throws {
        self.models.removeAll {
            type(of: $0) == type(of: model)
                && $0.id == model.id
        }
        self.logger.info(
            "Deleted simulation model \(type(of: model))"
        )
        print("Deleted simulation model \(model)")
    }
}
