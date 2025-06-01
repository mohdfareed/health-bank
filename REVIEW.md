# Health Bank - Development Knowledge Base

## Architecture
- **Data Sources**: SwiftData (app-created data), HealthKit (external data), AppStorage (user preferences)
- **Units**: Apple Measurement API, store internally in base units
- **Sync**: Read from combined HealthKit+SwiftData, write to SwiftData first then sync to HealthKit

## Key Constraints
- Only `.local` source records are editable (not HealthKit data)
- Models implement `DataRecord` protocol
- Always use latest Swift features and animate UI changes by default

## ✅ COMPLETED: Universal UI Component Architecture

### Core Components
- **Field Definition Registry**: Centralized field properties in `Fields.swift` (FieldDefinition enum)
- **Universal Components**: `RecordField.swift` and `UniversalRecordRow.swift` for consistent UI
- **Record Mapping System**: `Records.swift` provides two key mappings:
  1. **Record → Field Definition**: `HealthRecord.fieldDefinition` extension maps record types to their field definitions
  2. **Record → RecordRow**: `recordRow(for:)` function maps record types to their edit forms

### Architecture Benefits
- **Single Source of Truth**: All field definitions centralized in FieldDefinition enum
- **Type Safety**: Proper generic constraints and Swift static property handling
- **Visual Consistency**: Maintains exact visual appearance across all contexts
- **Easy Extension**: Adding new record types requires minimal changes

### Current Implementation
```swift
// Records.swift provides two mappings:
extension HealthRecord {
    var fieldDefinition: Any? { /* maps to FieldDefinition.* */ }
}

@MainActor @ViewBuilder
func recordRow<Record: HealthRecord>(for record: Record) -> some View {
    /* maps to RecordRow + appropriate Form */
}
```

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
- ✅ Complete form system for all record types
- 🔄 Ready for HealthKit integration and live testing

## Next Steps
1. Test current record mapping system in DataView
2. Replace mock HealthKit service with real implementation
3. Add real-time updates and observer patterns
