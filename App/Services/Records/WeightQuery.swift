import Foundation

struct WeightQuery: HealthQuery {
    func fetch(from: Date, to: Date, store: HealthKitService) -> [Weight] {
        return []
    }
}
