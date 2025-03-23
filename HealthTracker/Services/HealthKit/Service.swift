import Foundation
import HealthKit
import SwiftData

final class HealthKitService {
    private let logger = AppLogger.new(for: HealthKitService.self)
    internal let healthStore: HKHealthStore
    internal static var isEnabled = false

    init() throws {
        guard HealthKitService.isAvailable else {
            throw HealthKitError.authorizationFailed(
                "HealthKit is not available on this device."
            )
        }
        self.healthStore = HKHealthStore()
        self.logger.debug("HealthKit service initialized.")
    }

    static func enable() async throws {
        Self.isEnabled = true
        let logger = AppLogger.new(for: HealthKitService.self)

        if !Self.isEnabled {
            logger.warning("HealthKit service is not available.")
            return
        }
        logger.info("HealthKit service started.")
    }

    static func disable() {
        Self.isEnabled = false
        let logger = AppLogger.new(for: HealthKitService.self)
        logger.info("HealthKit service disabled.")
    }

    // MARK: Operations

    func read<T: HealthKitModel>(desc: FetchDescriptor<T>? = nil) async throws -> [T] {
        guard self.canRead(T.self) else { return [] }
        return try await withCheckedThrowingContinuation { continuation in
            let query: HKQuery
            do {
                query = try T.healthKitQuery(with: desc) { _, results, err in
                    if let err = err {
                        continuation.resume(
                            throwing: HealthKitError.queryError(
                                "Failed to execute HealthKit query: \(query)", err))
                    } else {
                        continuation.resume(returning: results)
                    }
                }
            } catch {
                continuation.resume(throwing: error)
                return
            }
            healthStore.execute(query)
        }
    }

    func write<T: HealthKitModel>(_ object: T) async throws {
        guard self.canEdit(T.self) && self.isEditable(object) else {
            return
        }

        return try await withCheckedThrowingContinuation { continuation in
            healthStore.save(object.healthKitObjects) { _, error in
                if let error = error {
                    continuation.resume(
                        throwing: HealthKitError.queryError(
                            "Failed to save HealthKit object: \(object)", error))
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    func delete<T: HealthKitModel>(_ object: T) async throws {
        guard self.canEdit(T.self) && self.isEditable(object) else {
            return
        }

        return try await withCheckedThrowingContinuation { continuation in
            healthStore.delete(object.healthKitObjects) { _, error in
                if let error = error {
                    continuation.resume(
                        throwing: HealthKitError.queryError(
                            "Failed to delete HealthKit object: \(object)", error))
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
