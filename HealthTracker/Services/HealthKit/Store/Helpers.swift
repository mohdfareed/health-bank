import Foundation
import HealthKit
import SwiftData
//
///// A HealthKit data definition.
//struct HealthKitDataDefinition<Sample: Any, Value: Any> {
//    var type: HKSampleType
//    var unit: HKUnit
//}
//
//typealias AnyHealthKitDataDefinition = HealthKitDataDefinition<HKSampleType, HKUnit>
//
//struct HKQuantityService {
//    typealias DataDefinition = (type: HKQuantitySample, unit: HKUnit)
//}
//
//extension FetchDescriptor {
//    var nsPredicate: NSPredicate {
//        return NSPredicate { _, _ in true }
//    }
//}
//
//extension HealthKitDataDefinition {
//    /// Create a list of samples matching the data's type.
//    func fromCorrelation(_ correlation: HKCorrelation) throws -> [Value] {
//        return try correlation.objects(for: self.type).map(parseSample)
//    }
//
//    /// Create a HealthKit sample according to the data's type.
//    func sample(_ sample: HKSample) throws -> Sample {
//        guard self.type == sample.sampleType else {
//            throw HealthKitError.DataTypeMismatch(
//                expected: self.type.description,
//                actual: sample.sampleType.description
//            )
//        }
//        guard let newSample = sample as? Sample else {
//            throw HealthKitError.DataTypeMismatch(
//                expected: "\(Sample.self)",
//                actual: sample.description
//            )
//        }
//        return newSample
//    }
//
//    private func parseSample(_ sample: HKSample) throws -> Value {
//        guard let sample = sample as? Sample else {
//            throw HealthKitError.DataTypeMismatch(
//                expected: "\(Sample.self)",
//                actual: sample.description
//            )
//        }
//    }
//}
