# Analytics Dashboard Documentation

## Overview

The new Analytics Dashboard provides comprehensive health tracking insights using HealthKit data and advanced analytics services. It features five specialized widgets that leverage running averages, maintenance calorie estimation, and trend analysis.

## Widget Architecture

### 1. Budget Overview Widget
**Purpose**: Real-time budget tracking with running average adjustments

**Features**:
- Displays remaining calories for the day
- Shows base budget vs adjusted budget (with 7-day running average)
- Progress bar indicating daily consumption
- Color-coded feedback (green for on-track, red for over-budget)

**Data Sources**:
- HealthKit dietary calories (past 7 days)
- Running average calculation via AnalyticsService
- Budget adjustment via BudgetService

**Technical Implementation**:
```swift
// Calculates 7-day running average adjustment
let adjustedBudget = budgetService.calculateAdjustedBudget(
    baseBudget: baseBudget,
    averageIntake: averageIntake
)
```

### 2. Maintenance Discovery Widget
**Purpose**: Estimates maintenance calories based on weight/calorie correlation

**Features**:
- Shows estimated daily maintenance calories
- Displays current deficit/surplus
- Confidence indicator based on data quality
- Helps with strategic budget planning

**Data Sources**:
- HealthKit body mass (past 30 days)
- HealthKit dietary calories (past 30 days)
- Correlation analysis via AnalyticsService

**Technical Implementation**:
```swift
// Uses weight trend correlation for maintenance estimation
let estimatedMaintenance = await analytics.estimateMaintenanceCalories(
    weightData: weightData,
    calorieData: calorieData,
    weightWindowDays: 14,
    calorieWindowDays: 7
)
```

### 3. Trend Analysis Widget
**Purpose**: Shows weight and calorie trends with visual indicators

**Features**:
- Weekly weight change with direction arrows
- Weekly calorie change trends
- Color-coded indicators (green for weight loss, red for gain)
- Helps identify patterns in behavior

**Data Sources**:
- HealthKit data (past 14 days)
- Custom trend calculation comparing first/second half averages

### 4. Performance Metrics Widget
**Purpose**: Displays key performance indicators for tracking consistency

**Features**:
- Average daily calories and weight
- Calorie consistency score (inverse coefficient of variation)
- Data completeness percentage
- Progress bars for visual feedback

**Data Sources**:
- HealthKit statistics aggregation
- Statistical analysis for consistency metrics

### 5. Weekly Summary Widget
**Purpose**: Comprehensive overview of the past week's performance

**Features**:
- Total weekly calories consumed
- Daily average calculations
- Weekly weight change
- Days tracked counter

**Data Sources**:
- 7-day HealthKit statistics
- Weight change analysis using 14-day comparison

## Technical Architecture

### Data Flow
1. **HealthKit Integration**: Each widget uses `HealthKitService.shared` to fetch statistics
2. **Analytics Processing**: Raw data is processed through `AnalyticsService` for running averages and correlations
3. **Budget Calculations**: `BudgetService` provides budget adjustments and maintenance comparisons
4. **Reactive Updates**: Widgets automatically refresh when HealthKit data changes

### Key Services Used

#### HealthKitStatistics
- Provides time-bucketed data (daily, weekly, monthly)
- Handles unit conversions automatically
- Uses `HKStatisticsCollectionQuery` for efficient data retrieval

#### AnalyticsService
- `calculateRunningAverage()`: Configurable window running averages
- `estimateMaintenanceCalories()`: Weight/calorie correlation analysis
- Statistical utilities for trend calculations

#### BudgetService
- `calculateAdjustedBudget()`: Base budget + running average adjustment
- Simple deficit/surplus tracking

### Performance Considerations
- Async data loading with loading states
- Efficient HealthKit queries using specific date ranges
- Cached service instances to avoid repeated initialization
- Sendable compliance for data race safety

## Widget Interaction Patterns

### Loading States
All widgets implement a consistent loading pattern:
```swift
@State private var isLoading = true
// Content loads asynchronously
if isLoading {
    ProgressView()
} else if let data = widgetData {
    // Display content
} else {
    // Error state
}
```

### Data Refresh
Widgets automatically refresh when:
- View appears
- HealthKit data is updated
- User grants new permissions

### Error Handling
- Graceful degradation when insufficient data
- Clear messaging for data requirements
- Fallback values for missing information

## Customization Options

### Time Windows
- Running averages: Configurable window sizes (default 7 days)
- Maintenance estimation: Separate weight/calorie windows
- Trend analysis: Configurable analysis periods

### Visual Design
- Color-coded progress indicators
- Consistent card-based layout
- Responsive grid system
- Modern SF Symbols integration

## Future Enhancements

### Planned Features
1. **Navigation to Detailed Views**: Tap widgets to see detailed charts
2. **Customizable Thresholds**: User-defined targets and alerts
3. **Export Capabilities**: Share analytics data
4. **Predictive Analytics**: Forecast trends based on current patterns

### Technical Improvements
1. **Widget Refresh Strategy**: Smart caching and background updates
2. **Performance Optimization**: Reduce HealthKit query frequency
3. **Accessibility**: Enhanced VoiceOver support
4. **Unit Preferences**: Respect user's preferred measurement units

## Integration with Existing Architecture

The analytics dashboard seamlessly integrates with the existing HealthVaults architecture:
- Uses shared HealthKit service instance
- Leverages existing measurement system
- Follows established error handling patterns
- Maintains consistency with design system

The dashboard serves as the primary entry point for users to understand their health trends and make informed decisions about their nutrition and fitness goals.
