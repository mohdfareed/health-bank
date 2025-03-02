import Foundation
import SwiftData

/// User settings.
@Model
final class AppSettings {
    /// Active budget name.
    var activeBudget: String?
    /// Enable HealthKit integration.
    var enableHealthKit: Bool
    /// Write manual entries to HealthKit.
    var writeToHealthKit: Bool = false

    init(
        activeBudget: String? = nil,
        enableHealthKit: Bool = false,
        writeToHealthKit: Bool = false
    ) {
        self.enableHealthKit = enableHealthKit
        self.writeToHealthKit = writeToHealthKit
    }
}

/// App state and user choices.
@Model
final class AppState {
    /// Whether the user has responded to `Settings.enableHealthKit`.
    var hasRespondedToEnableHealthKit: Bool = false
    /// Whether the user has responded to `Settings.writeToHealthKit`.
    var hasRespondedToWriteToHealthKit: Bool = false

    init(
        hasRespondedToEnableHealthKit: Bool = false,
        hasRespondedToWriteToHealthKit: Bool = false
    ) {
        self.hasRespondedToEnableHealthKit = hasRespondedToEnableHealthKit
        self.hasRespondedToWriteToHealthKit = hasRespondedToWriteToHealthKit
    }
}
