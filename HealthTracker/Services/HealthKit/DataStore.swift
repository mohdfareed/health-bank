import Foundation
import HealthKit
import SwiftData

final class HealthKitStore: DataStore {
    typealias Configuration = HealthKitStoreConfiguration
    typealias Snapshot = DefaultSnapshot

    var identifier = UUID().uuidString
    var configuration: Configuration
    var schema: Schema

    private var logger = AppLogger.new(for: HealthKitStore.self)
    private var service: HealthKitService?

    var healthService: HealthKitService? {
        guard HealthKitService.isEnabled else {
            return nil
        }
        return self.service
    }

    init(
        _ configuration: HealthKitStoreConfiguration,
        migrationPlan: (any SchemaMigrationPlan.Type)?
    ) throws {
        self.configuration = configuration
        self.schema = configuration.schema ?? Configuration().schema!
        if HKHealthStore.isHealthDataAvailable() {
            self.service = try HealthKitService()
        }
    }

    func fetch<T>(_ request: DataStoreFetchRequest<T>)
        async throws -> DataStoreFetchResult<T, T>
    where T: PersistentModel {
        guard let service = self.healthService else {
            return DataStoreFetchResult(
                descriptor: request.descriptor,
                fetchedSnapshots: [],
                relatedSnapshots: [:]
            )
        }

        // TODO: Convert persistent model to health kit model.
        // var modelType = T.self as! HealthKitType
        var models = try await service.read(desc: request.descriptor)
        var results = [PersistentIdentifier: DataStoreSnapshot]()
        for model in models {
            results[model.id] = model
        }

        let snapshots = results.values.map({ $0 })
        return DataStoreFetchResult(
            descriptor: request.descriptor,
            fetchedSnapshots: snapshots,
            relatedSnapshots: results
        )
    }

    func save(_ request: DataStoreSaveChangesRequest<DefaultSnapshot>)
        throws -> DataStoreSaveChangesResult<DefaultSnapshot>
    {
        guard let service = self.healthService else {
            return DataStoreSaveChangesResult(for: self.identifier)
        }

        var remappedIdentifiers = [PersistentIdentifier: PersistentIdentifier]()
        var modelData = [PersistentIdentifier: DefaultSnapshot]()
        for snapshot in request.inserted {
            let permanentIdentifier = try PersistentIdentifier.identifier(
                for: identifier,
                entityName: snapshot.persistentIdentifier.entityName,
                primaryKey: UUID())

            let permanentSnapshot = snapshot.copy(persistentIdentifier: permanentIdentifier)
            modelData[permanentIdentifier] = permanentSnapshot
            remappedIdentifiers[snapshot.persistentIdentifier] = permanentIdentifier

            try service.write(permanentSnapshot.)
        }

        for snapshot in request.updated {
            modelData[snapshot.persistentIdentifier] = snapshot
            try service.write(snapshot)
        }

        for snapshot in request.deleted {
            modelData.removeValue(forKey: snapshot.persistentIdentifier)
            try service.delete(snapshot)
        }

        return DataStoreSaveChangesResult<DefaultSnapshot>(
            for: self.identifier,
            remappedIdentifiers: remappedIdentifiers,
            snapshotsToReregister: modelData
        )
    }
}

extension Dictionary {
    public func map<K,V>(_ transform: (Key, Value) throws -> (K,V)) rethrows -> [K:V] {
        var result: [K:V] = [:]
        for (k,v) in self {
            let (mk,mv) = try transform(k,v)
            result[mk] = mv
        }
        return result
    }

    public func playground() {

        let decoder = JSONDecoder()
        let encoder = JSONEncoder()

        let model = ConsumedCalories(1000, macros: CalorieMacros(), on: Date())
//        let data = ConsumedCalories

//        let decoder = JSONDecoder()
//        // decoder.dateDecodingStrategy = .iso8601
//        let trips = try decoder.decode([DefaultSnapshot].self, from: model.)

//        let snapshot = DefaultSnapshot(from: decoder)
        var data = [model.id:model]
        let snapshot = DefaultSnapshot(from: model, relatedBackingDatas: &data)
//        Backing


    }
}

extension ConsumedCalories: BackingData {
    
}
