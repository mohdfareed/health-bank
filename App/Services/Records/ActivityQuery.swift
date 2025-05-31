import Foundation

struct ActivityQuery: HealthQuery {
    func fetch(from: Date, to: Date, store: HealthKitService)
        -> [ActiveEnergy]
    {
        return []
    }
}
