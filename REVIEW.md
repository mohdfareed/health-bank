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

## Component Patterns
- **Foundation**: `MeasurementRow<UnitType>`
- **Rows**: Compact list display used by various models and views

## Animation Guidelines
- **Pattern**: All UI changes animated by default using modern SwiftUI transition APIs

## Unified Data Query System Design Session

### Objectives
- Create SwiftData @Query-like system for combined SwiftData + HealthKit data
- Abstract HealthKit complexity while maintaining query flexibility
- Support opt-in model participation (Weight, Calorie, Activity - not Goals)

### Key Requirements
- **Data Combining**: "Remove all local entries from HealthKit results" (simple deduplication)
- **Real-time Updates**: Future requirement, not immediate
- **Query Interface**: Generic @UnifiedQuery with model-specific adapters (Option B selected)
- **Performance**: Handle large datasets (yearly calorie views)
- **Sync System**: SwiftData → HealthKit queue with offline resilience
- **Permissions**: Transparent HealthKit authorization handling

### Design Decisions
- **✅ Option B**: Generic Query with Model Adapters
  - SwiftData-like syntax: `@UnifiedQuery(filter: \.date > lastWeek, sort: \.date)`
  - Model-specific adapters handle HealthKit complexity behind the scenes

### **🔄 ARCHITECTURE PIVOT**: Model-Specific Query Extensions
- **Problem**: Generic filters can't handle HealthKit's diverse query patterns (correlation, statistics, etc.)
- **Solution**: Each model defines its own `UnifiedQuery` initializers with model-appropriate parameters
- **Architecture**:
  - HealthKit service injected into environment
  - `@UnifiedQuery` uses `@Query` internally + HealthKit service
  - Model extensions provide appropriate initializers
  - Model opt-in: Extension existence enables support
- **Example**:
  ```swift
  // For Calorie model - handles correlation queries for macros
  @UnifiedQuery(dateRange: lastWeek, minCalories: 100) var calories: [Calorie]

  // For Weight model - simple sample queries
  @UnifiedQuery(dateRange: lastMonth, source: .all) var weights: [Weight]

  // For Activity model - workout-specific queries
  @UnifiedQuery(dateRange: today, activityType: .running) var activities: [Activity]
  ```

## Interface Design Phase

### Core Components
1. **HealthKitService**: Environment-injected service for HealthKit operations
2. **UnifiedQuery**: Property wrapper combining SwiftData @Query + HealthKit
3. **Model Extensions**: Define model-specific initializers and query logic

### Interface Definitions

#### 1. HealthKitService Protocol
```swift
@MainActor
protocol HealthKitService: AnyObject {
    var isAvailable: Bool { get }
    var isAuthorized: Bool { get async }
    func requestAuthorization() async throws
    func query<T: DataRecord>(_ type: T.Type, with parameters: QueryParameters) async throws -> [T]
}
```

#### 2. UnifiedQuery Property Wrapper
```swift
@MainActor @propertyWrapper
struct UnifiedQuery<T: UnifiedQueryable>: DynamicProperty {
    var wrappedValue: [T] // Combined SwiftData + HealthKit results
    var isLoading: Bool   // Loading state

    init(parameters: T.QueryParams, predicate: Predicate<T>, sortBy: [SortDescriptor<T>])
}
```

#### 3. Supporting Protocols
```swift
protocol UnifiedQueryable: DataRecord where Self: PersistentModel {
    associatedtype QueryParams: QueryParameters
}

protocol QueryParameters {
    var dateRange: ClosedRange<Date>? { get }
}
```

#### 4. Model-Specific Extensions (Example: Weight)
```swift
// Query parameters for Weight
struct WeightQueryParams: QueryParameters {
    let dateRange: ClosedRange<Date>?
    let minWeight: Double?
    let maxWeight: Double?
}

// Enable UnifiedQuery support
extension Weight: UnifiedQueryable {
    typealias QueryParams = WeightQueryParams
}

// Model-specific initializers
extension UnifiedQuery where T == Weight {
    init(dateRange: ClosedRange<Date>) { /* SwiftData predicate + HealthKit params */ }
    init(dateRange: ClosedRange<Date>, weightRange: ClosedRange<Double>) { /* ... */ }
    init(recent: Bool = true) { /* Last 30 days */ }
}
```

#### 5. Usage Examples
```swift
struct WeightListView: View {
    @UnifiedQuery(recent: true) var recentWeights: [Weight]
    @UnifiedQuery(dateRange: lastMonth) var monthlyWeights: [Weight]

    var body: some View {
        List(recentWeights, id: \.date) { weight in
            Text("\(weight.weight) kg")
        }
    }
}
```

## Data Flow Architecture

```mermaid
graph TD
    A[SwiftUI View] --> B[@UnifiedQuery Property Wrapper]
    B --> C[SwiftData @Query]
    B --> D[HealthKitService]

    C --> E[Local Records]
    D --> F[HealthKit Store]
    F --> G[HealthKit Records]

    E --> H[Deduplication Logic]
    G --> H
    H --> I[Combined Results]
    I --> A

    J[Model Extension] --> B
    J --> K[Query Parameters]
    J --> L[SwiftData Predicate]
    K --> D
    L --> C
```

## 🎯 Final Architecture Design - UnifiedQuery System

### ✅ Design Decisions Confirmed
- **Data Combining**: `@State` + background tasks for HealthKit, `@Query` for SwiftData
- **HealthKit Integration**: Environment-injected service
- **Loading States**: `isLoading: Bool` + `refresh()` method
- **Deduplication**: Filter HealthKit results where `source != .local`
- **Initial Load**: Wait for both SwiftData + HealthKit before showing data
- **Testing**: 2-second simulated delay for HealthKit queries

### 📊 Data Flow Architecture

```mermaid
graph TD
    A[SwiftUI View] --> B[@UnifiedQuery Property Wrapper]

    B --> C[@Query localData]
    B --> D[@State healthKitData]
    B --> E[@State isLoading]
    B --> F[@Environment healthKitService]

    C --> G[SwiftData Store]
    F --> H[HealthKit Store]

    I[Initial Load] --> J[Start Loading State]
    J --> K[Fetch SwiftData - Immediate]
    J --> L[Fetch HealthKit - Async + 2s delay]

    K --> M[Local Results Ready]
    L --> N[HealthKit Results Ready]

    M --> O{Both Ready?}
    N --> O
    O -->|Yes| P[Combine & Deduplicate]
    O -->|No| Q[Keep Loading]

    P --> R[Filter: Remove HealthKit items where source == .local]
    R --> S[Merge: localData + filteredHealthKit]
    S --> T[Sort Combined Results]
    T --> U[Update wrappedValue]
    U --> A

    V[Manual Refresh] --> W[Trigger HealthKit Re-fetch]
    W --> L
```

### 🔧 Core Interface Structure

```swift
@MainActor @propertyWrapper
struct UnifiedQuery<T: DataRecord & PersistentModel>: DynamicProperty {
    @Query private var localData: [T]           // Auto-updating SwiftData
    @State private var healthKitData: [T] = []  // HealthKit results
    @State private var isLoading = false        // Loading state
    @Environment(\.healthKitService) var healthKit

    var wrappedValue: [T] {
        // Combine + deduplicate: Remove HealthKit items where source == .local
        let filtered = healthKitData.filter { $0.source != .local }
        return (localData + filtered).sorted { $0.date > $1.date }
    }

    func refresh() { /* Manual HealthKit re-fetch with 2s delay */ }
}
```

### 📝 Usage Examples
```swift
struct WeightListView: View {
    @UnifiedQuery(recent: true) var weights: [Weight]

    var body: some View {
        List(weights, id: \.date) { weight in
            Text("\(weight.weight) kg")
        }
        .refreshable { weights.refresh() }
        .overlay {
            if weights.isLoading {
                ProgressView("Loading...")
            }
        }
    }
}
```

## ✅ Implementation Complete - UnifiedQuery System

### 🎯 Successfully Implemented Components

1. **HealthKitService** (`Services/HealthKitService.swift`)
   - Protocol with `queryWeights()` method
   - `MockHealthKitService` with 2-second delay simulation
   - Environment integration with `HealthKitServiceKey`
   - Sendable compliance for SwiftUI environment

2. **Enhanced UnifiedQuery** (`Services/UnifiedQuery.swift`)
   - Property wrapper with `@Query` + `@State` combination
   - Data combining logic: `localData + filteredHealthKit`
   - Deduplication: Filters HealthKit where `source != .local`
   - Loading state management with `isLoading: Bool`
   - Manual refresh capability with `refresh()` method
   - Automatic date sorting (most recent first)

3. **Updated WeightService** (`Services/Records/WeightService.swift`)
   - Model-specific query extensions for Weight
   - All initializers now pass `dateRange` parameter to HealthKit
   - Three query patterns: `recent`, `dateRange`, `dateRange + weightRange`

4. **Test View** (`Views/Test/UnifiedQueryTestView.swift`)
   - Demonstrates unified data display with source indicators
   - Loading state overlay with progress indicator
   - Pull-to-refresh functionality
   - Proper environment setup with mock service

### 🔄 Data Flow Implementation

```swift
// Usage example - exactly as designed
@UnifiedQuery(recent: true) var weights: [Weight]

// Internal flow:
// 1. SwiftData @Query provides immediate local results
// 2. HealthKit service queries with 2s delay simulation
// 3. Results combined and deduplicated by source
// 4. UI updates automatically via @State changes
```

### 🧪 Testing Status
- **Architecture**: ✅ Implemented
- **Compilation**: ✅ No errors
- **Mock Service**: ✅ 2-second delay simulation
- **UI Integration**: ✅ Integrated into Data tab
- **App Launch**: ✅ Ready for live testing
- **Sample Data**: ✅ Preview includes test Weight entries

### 🎯 Final Implementation Summary

**Complete UnifiedQuery System:**
1. **Property Wrapper**: Combines `@Query` (SwiftData) + `@State` (HealthKit)
2. **Data Combining**: Automatic deduplication by source filtering
3. **Loading States**: Exposed via projected value (`$query.isLoading`)
4. **Manual Refresh**: Pull-to-refresh and programmatic refresh
5. **Environment Integration**: Mock service with 2s delay
6. **Model Extensions**: Weight queries (recent, dateRange, weightRange)

**Ready for:**
- Live testing with the launched app
- Real HealthKit integration (replace MockHealthKitService)
- Additional models (Calorie, Activity support)
- Observer pattern implementation for real-time updates

## Next Steps

1. **Live Testing**: Build and test with sample Weight data
2. **HealthKit Integration**: Replace mock with real HealthKit queries
3. **Expand Models**: Add Calorie and Activity support
4. **Observer Queries**: Add HealthKit observer pattern for real-time updates
