import Foundation

struct DietaryQuery: HealthQuery {
    func fetch(from: Date, to: Date, store: HealthKitService)
        -> [DietaryCalorie]
    {
        return []
    }
}

struct RestingQuery: HealthQuery {
    func fetch(from: Date, to: Date, store: HealthKitService)
        -> [RestingEnergy]
    {
        return []
    }
}
