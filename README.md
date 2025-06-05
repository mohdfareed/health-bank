# HealthBank

HealthBank is an iOS application designed for flexible and insightful health tracking. It allows users to monitor various health metrics such as calories (intake and expenditure), macro-nutrients (protein, carbohydrates, fat), and weight. The app integrates with Apple HealthKit to consolidate data from various sources and uses SwiftData for its local storage, ensuring that app-generated data is always available and synchronized.

Key features include aggregated data visualization and flexible time-based budgeting (e.g., weekly or custom periods rather than strict daily limits), catering to users who prefer a more adaptable approach to health management.

## Adding New Data

1. Add a model in `Models/`
2. Create a query in `Services/Data/`
