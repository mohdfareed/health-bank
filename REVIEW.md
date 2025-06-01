# Health Bank - Development Knowledge Base

#### Requirements (CONFIRMED)
- **Read-Only Access**: Weight, Dietary Energy, Active Energy, Basal Energy, Macro Nutrients
- **Error Handling**: Service has isEnabled flag + authorization + availability = active state; return empty results if inactive; log errors but don't propagate
- **Data Flow**: One-way read from HealthKit, no observer queries or real-time updates
- **Query Interface**: Each HealthQuery implementation must implement:
  - `fetch(from: Date, to: Date, store: HealthKitService) -> [Record]`
  - `predicate(from: Date, to: Date) -> Predicate<Record>`
- **Settings**: `Settings.enableHealthKit` defaults to `true` (opt-out model)
- **Base Units**:
  - Weight: kilograms
  - All calories: kilocalories
  - Macro nutrients: grams
  - Activity duration: minutes

### Architecture Design (CONFIRMED)
- **HealthKit Type Mapping**: ✅ Confirmed (bodyMass, dietaryEnergyConsumed, etc.)
- **Responsibility Split**: Model logic in Query implementations, HealthKit logic in Service
- **Macro Correlation**: Handle directly within `DietaryQuery.fetch()` method
- **State Management**: Service handles its own active state checkinge
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

## 🔄 COMPLETED: HealthKit Integration System

### Session Objective ✅
Implemented HealthKit integration functions in the `HealthQuery` protocol implementations to fetch health data from Apple HealthKit and synchronize with SwiftData.

### Requirements (CONFIRMED & IMPLEMENTED) ✅
- **Read-Only Access**: Weight, Dietary Energy, Active Energy, Basal Energy, Macro Nutrients
- **Error Handling**: Service has isEnabled flag + authorization + availability = active state; return empty results if inactive; log errors but don't propagate
- **Data Flow**: One-way read from HealthKit, no observer queries or real-time updates
- **Query Interface**: Each HealthQuery implementation implements:
  - `@MainActor func fetch(from: Date, to: Date, store: HealthKitService) async -> [Record]`
  - `func predicate(from: Date, to: Date) -> Predicate<Record>`
- **Settings**: `Settings.enableHealthKit` defaults to `true` (opt-out model)
- **Base Units**:
  - Weight: kilograms
  - All calories: kilocalories
  - Macro nutrients: grams
  - Activity duration: minutes

### Final Implementation State ✅
- **HealthKitService**: Complete service with authorization, query execution, and environment integration
  - Fixed: Removed `@MainActor`, uses `UserDefaults` directly, implements `Sendable`
  - Methods: `requestAuthorization()`, `fetchQuantitySamples()`, `fetchCorrelationSamples()`
  - State: `isActive` computed from availability + settings + authorization
- **Query Protocols**: `@MainActor HealthQuery` protocol with async interface
- **Complete Implementations**: All queries implement actual HealthKit data fetching:
  - `WeightQuery.fetch()` - fetches HK body mass samples
  - `DietaryQuery.fetch()` - fetches HK dietary energy + correlation food data
  - `RestingQuery.fetch()` - fetches HK basal energy samples
  - `ActivityQuery.fetch()` - fetches HK active energy samples
- **Data Models**: Clean SwiftData models (no Sendable markers)
- **Units Architecture**: ✅ Centralized `Units.swift` with `UnitDefinition` extensions
- **Actor Safety**: All components properly handle actor isolation without making models Sendable

## ✅ FINAL DESIGN: HealthKit Query System

### Service Interface
```swift
// HealthKitService: Sendable (but not @MainActor)
func requestAuthorization()  // Triggers authorization flow with logging
func fetchQuantitySamples(for:from:to:) async -> [HKQuantitySample]
func fetchCorrelationSamples(for:from:to:) async -> [HKCorrelation]
var isActive: Bool { UserDefaults.standard.bool(for: .enableHealthKit) && isAvailable }
```

### Query Implementation Pattern
```swift
// Each HealthQuery implementation (@MainActor)
@MainActor
func fetch(from: Date, to: Date, store: HealthKitService) async -> [Record] {
    guard store.isActive else { return [] }
    let samples = await store.fetchQuantitySamples(for: type, from: from, to: to)
    return samples.map { sample in
        Record(sample.quantity.baseUnitValue, date: sample.startDate, source: .healthKit)
    }
}

    // 1. Create HKSampleQuery for date range
    // 2. Execute via store.execute()
    // 3. Convert HKQuantitySample to models (in base units)
    // 4. For DietaryCalorie: fetch macro correlations directly
    // 5. Return [ModelType]
}
```

### Data Type Mappings
- `Weight` → `HKQuantityType(.bodyMass)` → kilograms
- `DietaryCalorie` → `HKQuantityType(.dietaryEnergyConsumed)` + macro correlations → kilocalories + grams
- `RestingEnergy` → `HKQuantityType(.basalEnergyBurned)` → kilocalories
- `ActiveEnergy` → `HKQuantityType(.activeEnergyBurned)` → kilocalories

### Next Implementation Steps
1. Complete HealthKitService with query execution methods
2. Add Settings.enableHealthKit definition
3. Implement WeightQuery.fetch() (simplest case)
4. Implement other query fetch methods
5. Test with authorization flow

### Requirements Defined
- **HealthKit Data Types**: Read-only access for Weight, Dietary Energy, Active Energy, Basal Energy, and Macro Nutrients
- **Correlation Queries**: Dietary calories need correlation with macro nutrients; other models may need similar complex queries
- **Data Flow**: One-way read from HealthKit, no observer queries or real-time updates
- **Error Handling**: Service has `isEnabled` flag + authorization + availability = active state. If inactive, return empty results. Log errors but don't propagate
- **Performance**: Basic implementation first, optimize later if needed
- **Query Ranges**: Primary focus on daily/weekly data, monthly/yearly for occasional reflection

### Refined Design Architecture

#### Service Interface
```swift
@MainActor
public final class HealthKitService {
    private let logger = AppLogger.new(for: HealthKitService.self)
    private let store = HKHealthStore()

    // Settings Integration
    @AppStorage(.enableHealthKit) private var isEnabled: Bool

    // Computed State
    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }
    var isActive: Bool { isEnabled && Self.isAvailable }

    // Core Methods
    func requestAuthorization(for types: Set<HKObjectType>) async throws
    func checkAuthorization(for type: HKObjectType) -> HKAuthorizationStatus
    func fetchQuantitySamples(for type: HKQuantityType, from: Date, to: Date) async -> [HKQuantitySample]
    func fetchCorrelationSamples(for type: HKCorrelationType, from: Date, to: Date) async -> [HKCorrelation]
    func fetchWorkouts(from: Date, to: Date) async -> [HKWorkout]
}
```

#### Settings Integration
- **New Setting**: `Settings.enableHealthKit: Settings<Bool>` with default `true`
- **Authorization**: Check per-type using `store.authorizationStatus(for:)` before queries
- **Permission Request**: Use `.healthDataAccessRequest()` modifier, not custom dialogs

#### ✅ RESOLVED: Unit Definition Layer
**Solution**: Create `Models/Core/Units.swift` with centralized unit definitions
**Required Units**:
- Weight: `.kilograms`
- Calories: `.kilocalories`
- Macros: `.grams`
- Duration: `.minutes`

**Implementation**: Move unit definitions from UI layer to Models layer for service access

#### Query-Model Mapping Strategy
Each `HealthQuery` implementation:
1. Checks `store.isActive` - returns `[]` if inactive
2. Checks authorization for required types - returns `[]` if denied
3. Fetches HealthKit data using appropriate method
4. Maps HealthKit objects to app models with `.healthKit` source
5. Logs errors but never throws/propagates them

#### Macro Handling
- Dietary calories: Fetch correlations when available
- Individual macros (protein, fat, carbs) marked nullable in `CalorieMacros`
- Only include macros when HealthKit correlation data exists

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
