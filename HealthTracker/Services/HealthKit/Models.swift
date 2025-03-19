import Foundation
import HealthKit
import SwiftData

// A protocol to support HealthKit data store.
protocol HealthKitModel: PersistentModel {
    associatedtype HealthKitType: HKSampleType
    associatedtype HealthKitQueryType: HKSampleQuery
    static func from(healthKitSample: HealthKitType) throws -> Self
    static func toHealthKitSample(from model: Self) throws -> HealthKitType
}

struct HealthKitStoreConfiguration: DataStoreConfiguration {
    typealias Store = HealthKitStore
    var name: String
    var schema: Schema?
}
