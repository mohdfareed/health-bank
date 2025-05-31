import Foundation
import HealthKit
import SwiftUI

// MARK: Service
// ============================================================================

/// Service for querying HealthKit data with model-specific query methods.
@MainActor
public final class HealthKitService {
    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }
}

// MARK: SwiftUI Integration
// ============================================================================

extension EnvironmentValues {
    /// The HealthKit service used for querying HealthKit data.
    @Entry var healthKit: HealthKitService = .init()
}

extension View {
    /// Sets the HealthKit service for the view's environment.
    func healthKit(_ service: HealthKitService) -> some View {
        environment(\.healthKit, service)
    }
}
