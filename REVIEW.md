# Health Bank - Development Knowledge Base

## Architecture
- **Data Sources**: SwiftData (app-created data), HealthKit (external data), AppStorage (user preferences)
- **Units**: Apple Measurement API, store internally in base units
- **Sync**: Read from combined HealthKit+SwiftData, write to SwiftData first then sync to HealthKit

## Key Constraints
- Only `.local` source records are editable (not HealthKit data)
- Models implement `DataRecord` protocol
- Always use latest Swift features and animate UI changes by default

## ✅ COMPLETED: Universal Forms Architecture

### Forms Architecture Pattern
- **RecordFormDefinition**: Generic struct in `Forms.swift` that holds form properties (title, etc.)
- **FormDefinition**: Enum in `Forms.swift` with static properties for each form type
- **RecordForm**: Universal component in `Components/RecordForm.swift` that takes a definition and builds the form

### Refactored Individual Forms
All forms now use the new `RecordForm` component with:
- **2-section structure**: "Data" section for form fields, "Data Source" section showing source icon and name
- **Automatic date handling**: `RecordForm` handles date picker in "Details" section
- **Consistent validation**: Each form provides validation logic through `isValid` binding
- **Data source display**: Shows HealthKit icon + "HealthKit" or local + "Health Bank" text
- **Unified save/delete**: `RecordForm` handles common form actions and navigation

### Updated Forms
- **WeightForm**: Basic weight entry with source display
- **DietaryCalorieForm**: Calorie entry with macro fields (protein, carbs, fat) grouped in Data section
- **ActiveEnergyForm**: Active calories with duration and workout type fields
- **RestingEnergyForm**: Simple resting energy entry

### Architecture Benefits
- **Consistent UI**: All forms follow identical structure and behavior
- **Centralized Logic**: Common form functionality in `RecordForm` component
- **Data Source Awareness**: Clear indication of where data originates
- **Validation**: Each form can define custom validation logic
- **Easy Maintenance**: Changes to form structure only need to be made in `RecordForm`

## ✅ COMPLETED: UnifiedQuery System

### Core Implementation
- **Property Wrapper**: Combines `@Query` (SwiftData) + `@State` (HealthKit)
- **Data Combining**: Automatic deduplication by source filtering
- **Loading States**: Exposed via projected value (`$query.isLoading`)
- **Manual Refresh**: Pull-to-refresh and programmatic refresh
- **Environment Integration**: HealthKitService with mock implementation

### Usage Pattern
```swift
@UnifiedQuery(WeightQuery()) var weights: [Weight]
@UnifiedQuery(DietaryQuery()) var calories: [DietaryCalorie]
```

## ✅ COMPLETED: Form System

### Record Forms
- **WeightForm**: Edit weight entries with validation
- **DietaryCalorieForm**: Edit calories with macro tracking (protein, carbs, fat)
- **ActiveEnergyForm**: Edit active calories with workout details (duration, type)
- **RestingEnergyForm**: Edit resting energy expenditure
- All forms support local record editing and deletion

### Integration
- Forms automatically linked through `recordRow(for:)` function in `Records.swift`
- Consistent navigation and validation across all record types
- Source-aware editing (only `.local` records are editable)

## Current Status
- ✅ Universal component architecture implemented
- ✅ UnifiedQuery system working with mock data
- ✅ Record definition system mapping records to UI components
- ✅ Universal forms architecture with RecordForm component
- ✅ All individual forms refactored to use new pattern
- ✅ Data source display (icon + name) implemented in all forms
- ✅ 2-section form structure (Data + Data Source) implemented
- 🔄 Ready for HealthKit integration and live testing

## Next Steps
1. Test current record mapping system in DataView
2. Replace mock HealthKit service with real implementation
3. Add real-time updates and observer patterns
