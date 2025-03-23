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
        if HealthKitService.isAvailable {
            self.service = try HealthKitService()
        }
    }

    func fetch<T>(_ request: DataStoreFetchRequest<T>)
        throws -> DataStoreFetchResult<T, DefaultSnapshot>
    where T: PersistentModel {
        guard let service = self.healthService,
              T.self is HealthKitType else {
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
    
    private func guardModelType<T>(
        _ request: DataStoreFetchRequest<T>
    ) throws -> DataStoreFetchRequest<T & HealthKitModel> {
        
    }

    private func createSnapshots(from models: [any HealthKitModel]) -> [DefaultSnapshot] {
    }

    private func fromSnapshots(_ snapshots: [DefaultSnapshot]) -> [any HealthKitModel] {
    }
    
    enum DataStoreError: Error {
        case notHealthModel
    }

    func fetch2<T>(_ request: DataStoreFetchRequest<T>) async throws -> DataStoreFetchResult<T, DefaultSnapshot>
        where T: PersistentModel {
            let healthKitType = T.self as! any HealthKitModel.Type
            guard let newRequest = try self.createRequest(request, for: healthKitType) else {
                    throw SomeError() // Replace with your actual error handling.
                }
            
        // Now you can use T.self directly without a forced cast.
        guard let newRequest = try self.createRequest(request, for: T.self) else {
            throw SomeError() // Replace with your actual error handling
        }
        let results = try await self.service?.read(desc: newRequest.descriptor)
        return try fetchHealth(request as! DataStoreFetchRequest<T>)
    }

    // The specialized version
    func fetchHealth<T>(_ request: DataStoreFetchRequest<T>) throws -> DataStoreFetchResult<T, DefaultSnapshot>
    where T: PersistentModel & HealthKitModel {
        // Your specialized implementation for HealthKitModel types.
        // …
    }
    
    // The specialized version
    func createRequest<T, U>(_ request: DataStoreFetchRequest<T>, for type: U.Type) throws -> DataStoreFetchRequest<U>?
    where T: PersistentModel, U: HealthKitModel {
        return request as? DataStoreFetchRequest<U>
    }
}
