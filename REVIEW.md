# Health Bank - Development Knowledge Base

## Architecture
- **Data Sources**: SwiftData (app-created data), HealthKit (external data), AppStorage (user preferences)
- **Units**: Apple Measurement API, store internally in base units
- **Sync**: Read from combined HealthKit+SwiftData, write to SwiftData first then sync to HealthKit

## Key Constraints
- Only `.local` source records are editable (not HealthKit data)
- Models implement `DataRecord` protocol
- Always use latest Swift features and animate UI changes by default

## Critical Issues & Solutions

### MeasurementField Null Values
- **Problem**: Cleared text fields reset to zero instead of nil
- **Solution**: Custom `textBinding` converts empty strings to nil, saves to SwiftData context

### Reactive Computed Values
- **Problem**: Computed fields (like BMI) weren't updating when dependencies changed
- **Solution**: Use closure syntax `computed: { calorie.calculatedProtein() }` instead of function references
- **Critical**: Single shared binding in views to maintain object identity for reactivity

### Generic DataViews
- **Problem**: Views were tightly coupled to specific model types
- **Solution**: Accept `Binding<Double?>` with convenience initializers for backward compatibility

## Component Patterns
- **Foundation**: `MeasurementField<UnitType>`, `CalorieField`, `DateField`, `DataSourceIndicator`
- **Rows**: Compact list display using DataRow pattern

## Animation Guidelines
- **Pattern**: All UI changes animated by default using modern SwiftUI transition APIs
