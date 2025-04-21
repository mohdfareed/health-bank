// import Foundation
// import HealthKit
// import SwiftData
// import Synchronization

// final class HealthKitService {
//     private let logger = AppLogger.new(for: Self.self)

//     internal static let healthStore: HKHealthStore? = {
//         guard HealthKitService.isAvailable else { return nil }
//         return HKHealthStore()
//     }()
//     internal static var isEnabled: Mutex<Bool> = Mutex(false)

//     init() throws {
//         guard HealthKitService.isAvailable else {
//             throw HealthKitError.authorizationFailed(
//                 "HealthKit is not available on this device."
//             )
//         }
//         self.healthStore = HKHealthStore()
//         self.logger.debug("HealthKit service initialized.")
//     }

//     static func enable() throws {
//         Self.isEnabled = HealthKitService.isAvailable
//         let logger = AppLogger.new(for: Self.self)

//         if !Self.isEnabled {
//             logger.warning("HealthKit service is not available.")
//             return
//         }
//         logger.info("HealthKit service started.")
//     }

//     static func disable() {
//         Self.isEnabled = false
//         let logger = AppLogger.new(for: Self.self)
//         logger.info("HealthKit service disabled.")
//     }

//     // MARK: Operations

//     func read<T: HealthKitModel>(desc: FetchDescriptor<T>? = nil) async throws -> [T] {
//         guard self.canRead(T.self) else { return [] }
//         return try await withCheckedThrowingContinuation { continuation in
//             let query: HKQuery
//             do {
//                 query = try T.healthKitQuery(with: desc) { _, results, err in
//                     guard let error = err else {
//                         continuation.resume(returning: results)
//                     }
//                     let newError = HealthKitError.queryError(
//                         "Failed to execute HealthKit query: \(query)", error
//                     )
//                     continuation.resume(throwing: newError)
//                 }
//             } catch {
//                 continuation.resume(throwing: error)
//                 return
//             }
//             healthStore.execute(query)
//         }
//     }

//     func write<T: HealthKitModel>(_ object: T) async throws {
//         guard self.canEdit(T.self) && self.isEditable(object) else { return }

//         do {
//             try await healthStore.save(object.healthKitObjects)
//         } catch {
//             throw HealthKitError.queryError(
//                 "Failed to save HealthKit object: \(object)", error
//             )
//         }
//     }

//     func delete<T: HealthKitModel>(_ object: T) async throws {
//         guard self.canEdit(T.self) && self.isEditable(object) else { return }

//         do {
//             try await healthStore.delete(object.healthKitObjects)
//         } catch {
//             throw HealthKitError.queryError(
//                 "Failed to delete HealthKit object: \(object)", error
//             )
//         }
//     }
// }
