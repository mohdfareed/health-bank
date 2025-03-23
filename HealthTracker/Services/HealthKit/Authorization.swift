import Foundation
import HealthKit
import SwiftData

extension HealthKitService {
    /// Whether HealthKit is available on the device.
    static var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    /// The minimum authorized sample date to read/write/delete.
    var minimumAuthorizedDate: Date {
        self.healthStore.earliestPermittedSampleDate()
    }

    /// Request authorization to read/write/delete health data.
    func requestAuthorization(for type: HealthKitType? = nil) async throws {
        try await self.healthStore.requestAuthorization(
            toShare: Self.writeSampleTypes(of: type),
            read: Self.readTypes(of: type)
        )
    }
    
    // MARK: Internal

    /// Whether the model can be read from HealthKit.
    internal func canRead<T: HealthKitModel>(_ type: T.Type) -> Bool {
        return Self.isEnabled
    }

    /// Whether the model can be written/deleted to HealthKit.
    internal func canEdit<T: HealthKitModel>(_ type: T.Type) -> Bool {
        return Self.isEnabled && self.hasWriteAuthorization(for: T.self)
    }

    /// Whether the model *instance* can be written/deleted to HealthKit.
    internal func isEditable<T: HealthKitModel>(_ objects: T...) -> Bool {
        let samples = objects.reduce([]) { $0 + $1.healthKitObjects }
        return samples.allSatisfy({
            if let sample = $0 as? HKSample {
                return sample.startDate >= self.minimumAuthorizedDate
            }
            return true
        })
    }

    // MARK: Private
    
    private func hasWriteAuthorization(for type: HealthKitType? = nil) -> Bool {
        return Self.writeTypes(of: type).allSatisfy({
            let status = self.healthStore.authorizationStatus(for: $0)
            return status == .sharingAuthorized
        })
    }

    private static func writeSampleTypes(
        of type: HealthKitType? = nil
    ) -> Set<HKSampleType> {
        let types = self.writeTypes(of: type).filter { $0 is HKSampleType }
        let sampleTypes = types.map { $0 as! HKSampleType }
        return Set(sampleTypes)
    }
    
    private static func writeTypes(
        of type: HealthKitType? = nil
    ) -> Set<HKObjectType> {
        guard let type = type else {
            let types = HealthKitStoreConfiguration.types.reduce(
                [], { $0 + $1.healthKitWriteTypes }
            )
            return Set(types)
        }
        return Set(type.healthKitWriteTypes)
    }

    private static func readTypes(
        of type: HealthKitType? = nil
    ) -> Set<HKObjectType> {
        guard let type = type else {
            let types = HealthKitStoreConfiguration.types.reduce(
                [], { $0 + $1.healthKitReadTypes }
            )
            return Set(types)
        }
        return Set(type.healthKitReadTypes)
    }
}
