import Foundation
import SwiftData

/// The user's daily goals.
@Model final class UserGoals: Singleton {
    var date: Date = Date()

    // goals
    var calories: Double? = 2000
    var macros: CalorieMacros? = nil
    var activity: TimeInterval? = 30

    // singleton
    var id: UUID
    required init(id: ID = .init()) { self.id = id }
}
