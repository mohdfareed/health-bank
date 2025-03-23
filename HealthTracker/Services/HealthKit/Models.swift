import Foundation
import HealthKit
import SwiftData

/// Configure the HealthKit data store.
struct HealthKitStoreConfiguration: DataStoreConfiguration {
    typealias Store = HealthKitStore
    var name: String = "HealthKit"
    var schema: Schema?

    /// The HealthKit store schema types.
    static let types: [HealthKitType] = [
        ConsumedCalories.Type
    ]()

    init(name: String? = nil) {
        self.name = name ?? self.name
    }
}

/// A protocol to support HealthKit data store.
protocol HealthKitModel: PersistentModel {
    /// The HealthKit samples the model writes/deletes.
    /// This is used to request authorization.
    static var healthKitWriteTypes: [HKObjectType] { get }

    /// The HealthKit objects the model reads.
    /// This is used to request authorization.
    static var healthKitReadTypes: [HKObjectType] { get }

    /// Create a HealthKit query for the model type.
    static func healthKitQuery(
        with descriptor: FetchDescriptor<Self>?,
        handler: @escaping (HKQuery, [Self], Error?) -> Void
    ) throws -> HKQuery

    /// The HealthKit objects representation of the model.
    /// This is the data to be written/deleted in HealthKit.
    var healthKitObjects: [HKSample] { get }
}

/// The type of any HealthKit model.
typealias HealthKitType = any HealthKitModel.Type

/// A HealthKit data model snapshot.
struct HealthKitSnapshot: DataStoreSnapshot {
    var persistentIdentifier: PersistentIdentifier

    init(
        from backingData: any BackingData,
        relatedBackingDatas: inout [PersistentIdentifier: any BackingData]
    ) {
    }

    func copy(
        persistentIdentifier: PersistentIdentifier,
        remappedIdentifiers: [PersistentIdentifier: PersistentIdentifier]? = nil
    ) -> HealthKitSnapshot {
    }
}

struct HealthKitBackingData: BackingData {
    typealias Model = ConsumedCalories
    
    var persistentModelID: PersistentIdentifier?
    
    var metadata: Any
    
    init(for modelType: ConsumedCalories.Type) {
        <#code#>
    }
    
    func getValue<Value>(forKey: KeyPath<ConsumedCalories, Value>) -> Value where Value : Decodable {
        <#code#>
    }
    
    func getValue<Value>(forKey: KeyPath<ConsumedCalories, Value?>) -> Value? where Value : PersistentModel {
        <#code#>
    }
    
    func getTransformableValue<Value>(forKey: KeyPath<ConsumedCalories, Value>) -> Value {
        <#code#>
    }
    
    func setValue<Value>(forKey: KeyPath<ConsumedCalories, Value>, to newValue: Value) where Value : Encodable {
        <#code#>
    }
    
    func setValue<Value>(forKey: KeyPath<ConsumedCalories, Value?>, to newValue: Value?) where Value : PersistentModel {
        <#code#>
    }
    
    func setTransformableValue<Value>(forKey: KeyPath<ConsumedCalories, Value>, to newValue: Value) {
        <#code#>
    }
}
