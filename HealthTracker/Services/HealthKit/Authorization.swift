import Foundation
import HealthKit
import SwiftData

extension HealthKitService {
    /// The minimum authorized sample date to read/write/delete.
    var minimumAuthorizedDate: Date {
        self.healthStore.earliestPermittedSampleDate()
    }

    /// Request authorization to read/write/delete health data.
    func requestAuthorization(for type: HealthKitType? = nil) async throws {
        try await self.healthStore.requestAuthorization(
            toShare: Self.writeTypes(of: type), read: Self.readTypes(of: type)
        )
    }

    /// Whether the app has write/delete authorization for the specified type.
    func hasWriteAuthorization(for type: HealthKitType? = nil) -> Bool {
        return Self.writeTypes(of: type).allSatisfy({
            let status = self.healthStore.authorizationStatus(for: $0)
            return status == .sharingAuthorized
        })
    }

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
        return objects.allSatisfy({
            if let entry = $0 as? any DataEntry {
                return entry.date >= self.minimumAuthorizedDate
            }
            return true
        })
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

}
