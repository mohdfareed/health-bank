/// The health data model types.
enum HealthDataModel: CaseIterable {
    case calorie
    case activity
    case resting
    case weight

    var dataType: any HealthDate.Type {
        switch self {
        case .calorie:
            return DietaryCalorie.self
        case .activity:
            return ActiveEnergy.self
        case .resting:
            return RestingEnergy.self
        case .weight:
            return Weight.self
        }
    }

    static var allTypes: [any HealthDate.Type] {
        allCases.map { $0.dataType }
    }
}
