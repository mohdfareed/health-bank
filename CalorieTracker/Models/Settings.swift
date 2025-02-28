import Foundation
import SwiftData

/// User settings.
@Model
final class Settings {

    /// Enable health kit integration.
    var enableHealthKit: Bool

    init(enableHealthKit: Bool) {
        self.enableHealthKit = enableHealthKit
    }
}
