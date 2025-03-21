import Foundation
import HealthKit
import SwiftData

typealias SupportedTypes = [any HealthKitModel.Type]

// A protocol to support HealthKit data store.
protocol HealthKitModel: PersistentModel {
    static var healthKitType: HKSampleType { get }
    static func healthKitDescriptor(with predicate: FetchDescriptor<Self>?) -> HKQueryDescriptor
}

struct HealthKitStoreConfiguration: DataStoreConfiguration {
    typealias Store = HealthKitStore
    var name: String = "HealthKit"
    var schema: Schema? = Schema(HealthKitStore.types)

    init(name: String? = nil) {
        self.name = name ?? self.name
    }
}

final class HealthKitStore: DataStore {
    typealias Configuration = HealthKitStoreConfiguration
    typealias Snapshot = DefaultSnapshot

    static let types: [any HealthKitModel.Type] = [

        ]

    var schema: Schema = Configuration().schema ?? Schema()
    var configuration: HealthKitStoreConfiguration
    var identifier: String = UUID().uuidString

    private var logger = AppLogger.new(for: HealthKitStore.self)
    private var healthStore = HKHealthStore()

    init(
        _ configuration: HealthKitStoreConfiguration,
        migrationPlan: (any SchemaMigrationPlan.Type)?
    ) throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.authorizationFailed(
                "HealthKit is not available on this device."
            )
        }

        self.configuration = configuration
        self.schema = configuration.schema ?? self.schema

        for modelType in HealthKitStore.types {
            let observerQuery = HKObserverQuery(sampleType: modelType.healthKitType, predicate: nil)
            { [weak self] query, completionHandler, error in
                // Fetch the new data for this model.
                self?.handleHealthKitUpdate(for: modelType)
                completionHandler()
            }
            healthStore.execute(observerQuery)
        }
    }

    func fetch<T>(_ request: DataStoreFetchRequest<T>)
        throws -> DataStoreFetchResult<T, DefaultSnapshot>
    where T: PersistentModel {
        let test = request.descriptor.predicate
        return DataStoreFetchResult(
            descriptor: request.descriptor, fetchedSnapshots: [DefaultSnapshot]([]))
    }

    func fetch<T>(_ request: DataStoreFetchRequest<T>)
        throws -> DataStoreFetchResult<T, DefaultSnapshot>
    where T: HealthKitModel {
        return DataStoreFetchResult(
            descriptor: request.descriptor, fetchedSnapshots: [DefaultSnapshot]([]))
    }

    func save(_ request: DataStoreSaveChangesRequest<DefaultSnapshot>) throws
        -> DataStoreSaveChangesResult<DefaultSnapshot>
    {
        return DataStoreSaveChangesResult(for: "")
    }
}
