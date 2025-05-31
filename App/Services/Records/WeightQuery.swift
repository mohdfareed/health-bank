import Foundation

struct WeightQuery: HealthQuery {
    func fetch(from: Date, to: Date, store: HealthKitService) -> [Weight] {
        return []
    }

    func predicate(from: Date, to: Date) -> Predicate<Weight> {
        return #Predicate {
            from <= $0.date && $0.date <= to
        }
    }
}
