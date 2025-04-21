// import Foundation
// import HealthKit
// import SwiftData

// final class HealthKitStore: DataStore {
//     typealias Configuration = HealthKitStoreConfiguration
//     typealias Snapshot = HealthKitSnapshot

//     var configuration: Configuration
//     var identifier: String
//     var schema: Schema

//     private var logger = AppLogger.new(for: Self.self)
//     private var service: HealthKitService?

//     var healthService: HealthKitService? {
//         guard HealthKitService.isEnabled else {
//             return nil
//         }
//         return self.service
//     }

//     init(
//         _ configuration: HealthKitStoreConfiguration, migrationPlan: (any SchemaMigrationPlan.Type)?
//     ) throws {
//         self.configuration = configuration
//         self.identifier = configuration.name
//         self.schema = configuration.schema ?? Configuration().schema!
//         if HealthKitService.isAvailable {
//             self.service = try HealthKitService()
//         }
//     }

//     func fetch<T>(_ request: DataStoreFetchRequest<T>)
//         throws -> DataStoreFetchResult<T, HealthKitSnapshot>
//     where T: PersistentModel {
//         self.logger.warning("Unsupported HealthKit model type: \(T.self)")
//         return DataStoreFetchResult(
//             descriptor: request.descriptor,
//             fetchedSnapshots: [],
//             relatedSnapshots: [:]
//         )
//     }

//     func fetch<T>(_ request: DataStoreFetchRequest<T>)
//         throws -> DataStoreFetchResult<T, HealthKitSnapshot>
//     where T: PersistentModel & HealthKitModel {
//         guard let service = self.healthService else {
//             return DataStoreFetchResult(
//                 descriptor: request.descriptor,
//                 fetchedSnapshots: [],
//                 relatedSnapshots: [:]
//             )
//         }

//         var models: [T]
//         let semaphore = DispatchSemaphore(value: 0)
//         Task {
//             models = try await service.read(desc: request.descriptor)
//             semaphore.signal()
//         }
//         semaphore.wait()

//         let snapshots = createSnapshots(from: models)
//         var results = [PersistentIdentifier: HealthKitSnapshot]()
//         for snapshot in snapshots {
//             results[snapshot.persistentIdentifier] = snapshot
//         }

//         return DataStoreFetchResult(
//             descriptor: request.descriptor,
//             fetchedSnapshots: snapshots,
//             relatedSnapshots: results
//         )
//     }

//     func save(_ request: DataStoreSaveChangesRequest<HealthKitSnapshot>)
//         throws -> DataStoreSaveChangesResult<HealthKitSnapshot>
//     {
//         guard let service = self.healthService else {
//             return DataStoreSaveChangesResult(for: self.identifier)
//         }

//         var remappedIdentifiers = [PersistentIdentifier: PersistentIdentifier]()
//         var modelData = [PersistentIdentifier: HealthKitSnapshot]()
//         for snapshot in request.inserted {
//             let permanentIdentifier = try PersistentIdentifier.identifier(
//                 for: identifier,
//                 entityName: snapshot.persistentIdentifier.entityName,
//                 primaryKey: UUID())

//             let permanentSnapshot = snapshot.copy(
//                 persistentIdentifier: permanentIdentifier,
//                 remappedIdentifiers: remappedIdentifiers

//             )
//             modelData[permanentIdentifier] = permanentSnapshot
//             remappedIdentifiers[snapshot.persistentIdentifier] = permanentIdentifier
//             Task { try await service.write(self.fromSnapshot(permanentSnapshot)) }
//         }

//         for snapshot in request.updated {
//             modelData[snapshot.persistentIdentifier] = snapshot
//             Task { try await service.write(self.fromSnapshot(snapshot)) }
//         }

//         for snapshot in request.deleted {
//             modelData.removeValue(forKey: snapshot.persistentIdentifier)
//             Task { try await service.delete(self.fromSnapshot(snapshot)) }
//         }

//         return DataStoreSaveChangesResult<HealthKitSnapshot>(
//             for: self.identifier,
//             remappedIdentifiers: remappedIdentifiers,
//             snapshotsToReregister: modelData
//         )
//     }

//     private func createSnapshots(from models: [any HealthKitModel]) -> [HealthKitSnapshot] {
//         var relatedData: [PersistentIdentifier: any BackingData]
//         for model in models {
//             relatedData[model.persistentModelID] = model
//         }
//         let snapshots = models.map {
//             HealthKitSnapshot(from: $0, relatedBackingDatas: &relatedData)
//         }
//         return snapshots
//     }

//     private func fromSnapshot(_ snapshot: HealthKitSnapshot) -> any HealthKitModel {
//     }
// }

// struct HealthKitSnapshot: DataStoreSnapshot {
//     var persistentIdentifier: PersistentIdentifier
//     var data: Data

//     init(
//         from: any BackingData,
//         relatedBackingDatas: inout [PersistentIdentifier: any BackingData]
//     ) {
//         self.persistentIdentifier = from.persistentModelID!
//         let data = from as! Encodable
//         self.data = try! JSONEncoder().encode(data)
//     }

//     private init(_ id: PersistentIdentifier, _ data: Data) {
//         self.persistentIdentifier = id
//         self.data = data
//     }

//     func copy(
//         persistentIdentifier: PersistentIdentifier,
//         remappedIdentifiers: [PersistentIdentifier: PersistentIdentifier]?
//     ) -> Self {
//         return HealthKitSnapshot(persistentIdentifier, self.data)
//     }

//     func create() -> any HealthKitModel {
//         // let model = try! JSONDecoder().decode(ConsumedCalories, from: self.data)
//         // let model = ConsumedCalories(100, macros: CalorieMacros(), on: Date())
//         // model.id = self.persistentIdentifier
//         // return model
//     }
// }
