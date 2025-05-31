import Foundation

struct ActivityQuery: HealthQuery {
    func fetch(from: Date, to: Date, store: HealthKitService)
        -> [ActiveEnergy]
    {
        return []
    }

    func predicate(from: Date, to: Date) -> Predicate<ActiveEnergy> {
        return #Predicate<ActiveEnergy> {
            from <= $0.date && $0.date <= to
        }
    }
}
