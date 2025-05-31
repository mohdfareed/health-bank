import Foundation

struct DietaryQuery: HealthQuery {
    func fetch(from: Date, to: Date, store: HealthKitService)
        -> [DietaryCalorie]
    {
        return []
    }

    func predicate(from: Date, to: Date) -> Predicate<DietaryCalorie> {
        return #Predicate {
            from <= $0.date && $0.date <= to
        }
    }
}

struct RestingQuery: HealthQuery {
    func fetch(from: Date, to: Date, store: HealthKitService)
        -> [RestingEnergy]
    {
        return []
    }

    func predicate(from: Date, to: Date) -> Predicate<RestingEnergy> {
        return #Predicate {
            from <= $0.date && $0.date <= to
        }
    }
}
