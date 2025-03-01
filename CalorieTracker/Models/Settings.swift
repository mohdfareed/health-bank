import Foundation
import SwiftData

/// User settings.
@Model
final class Settings {
    /// Enable HealthKit integration.
    var enableHealthKit: Bool
    /// Write manual entries to HealthKit.
    var writeToHealthKit: Bool = false

    init(enableHealthKit: Bool, writeToHealthKit: Bool = false) {
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

    init(hasRespondedToEnableHealthKit: Bool = false, hasRespondedToWriteToHealthKit: Bool = false)
    {
        self.hasRespondedToEnableHealthKit = hasRespondedToEnableHealthKit
        self.hasRespondedToWriteToHealthKit = hasRespondedToWriteToHealthKit
    }
}
