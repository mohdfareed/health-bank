# Health Bank - Engineer's Notebook

## Project Overview
Health Bank is an iOS app for tracking health metrics with these key characteristics:
- Tracks metrics from both local storage (SwiftData) and HealthKit
- Features include dietary tracking, calories burned, workouts, and weight
- Built with SwiftUI, SwiftData and HealthKit

## Current Architecture Diagram

```
┌───────────────────────────┬───────────────────────────┬─────────────────────────┐
│ MODELS                    │ SERVICES                  │ VIEWS                   │
├───────────────────────────┼───────────────────────────┼─────────────────────────┤
│ Data Models               │ Data Access               │ Main UI                 │
│                           │                           │                         │
│ ├─ DataRecord protocol    │ ├─ RemoteContext          │ ├─ AppView              │
│ │  ├─ CalorieRecord       │ │  └─ sync()/fetch()      │ │  └─ TabView           │
│ │  │  ├─ DietaryCalorie   │ │                         │ │     ├─ Dashboard      │
│ │  │  └─ BurnedCalorie    │ ├─ DataQuery<M> wrapper   │ │     ├─ Data           │
│ │  │     ├─ RestingCalorie│ │  └─ Combines sources    │ │     └─ Settings       │
│ │  │     └─ WorkoutRecord │ │                         │ │                       │
│ │  └─ WeightRecord        │ └─ CoreModels (duplicates)│ └─ [Many commented out] │
│ │                         │                           │                         │
│ Query System              │ HealthKit (commented out) │ Units & Measurements    │
│                           │                           │                         │
│ ├─ RemoteQuery protocol   │ ├─ HealthKitService       │ ├─ UnitDefinition       │
│ │  ├─ CalorieQuery        │ ├─ HealthKitStore         │ ├─ UnitProvider         │
│ │  ├─ MacrosQuery         │ ├─ HealthKitModel protocol│ ├─ UnitService          │
│ │  └─ WorkoutQuery        │ └─ Authorization          │ └─ LocalizedMeasurement │
└───────────────────────────┴───────────────────────────┴─────────────────────────┘
```

## Model Layer Refactoring

### Goal
Create a clean, maintainable model layer that follows best practices for SwiftData while supporting HealthKit integration.

### Changes Made (May 20, 2025)
1. **Unified Model Architecture**
   - ✅ Added clear protocol definitions for all model types
   - ✅ Made concrete SwiftData models implement these protocols
   - ✅ Added proper required initializers for SwiftData compatibility
   - ✅ Included `init(from decoder:)` for Codable conformance

2. **Protocol Hierarchy**
   - Added key protocols:
     - `DietaryCalorie` - For calories consumed from food
     - `BurnedCalorie` - Base for all calories burned
     - `RestingCalorie` - For BMR calories
     - `ActiveCalorie` - For activity calories
     - `Workout` - For workout-specific data
     - `Weight` - For weight tracking

3. **SwiftData Implementation**
   - ✅ Full implementation of `required init(instance:)` for SwiftData models
   - ✅ Proper value container usage for property decoding
   - ✅ Consistent property access patterns

4. **Next Steps**
   - Remove the duplicate `CoreDietaryCalorie` and similar classes in CoreModels.swift
   - Update service layer to use the Records.swift model classes directly

## Critical Issues Identified

### 1. Parallel Model Hierarchies
- Two separate but overlapping model hierarchies:
  - **Concrete SwiftData models** in Records.swift (DietaryCalorieRecord, etc.)
  - **Protocol-based models** referenced but not fully implemented (DietaryCalorie interface)
  - **Core models** in CoreModels.swift (CoreDietaryCalorie) that duplicate SwiftData models
- ✅ Now resolved with clear protocol definitions and implementations in Records.swift

### 2. HealthKit Integration Is Incomplete
- HealthKit implementation files are entirely commented out
- No concrete implementation of `RemoteStore` protocol that connects to HealthKit
- App.swift only initializes an empty RemoteContext with no stores
- Critical connection between SwiftData models and HealthKit is missing

### 3. Over-engineered Query System
- Multiple layers of abstraction for querying data:
  - FetchDescriptor extensions for basic SwiftData queries
  - RemoteQuery protocol and implementations for cross-source queries
  - InMemoryQuery for additional filtering
  - DataQuery property wrapper attempting to combine all sources
- Results in complex, hard-to-maintain code for simple data operations

### 4. Incomplete Views Layer
- Many view files are commented out or incomplete
- AppView.swift shows only Settings tabs, with no implementation of Dashboard or Data views

## Data Flow Diagnosis

### The Intended Flow (Based on Architecture)
1. **Data Sources:** Two primary sources tracked via DataSource enum:
   - `.local` - SwiftData persistence
   - `.healthKit` - Apple HealthKit

2. **Data Access Pattern:**
   - SwiftData serves as source of truth
   - Local records are queried via standard SwiftData mechanisms
   - HealthKit data should be queried via HealthKitService/Store
   - DataQuery wrapper combines both sources

3. **Unit Handling:**
   - Base units stored in models
   - Localized display units calculated via UnitDefinition and UnitService
   - Measurement formatting handled by LocalizedMeasurement wrapper

### The Actual Implementation Issues
1. **Incomplete HealthKit Integration:**
   - HealthKit files entirely commented out
   - No connection between SwiftData and HealthKit
   - App initializes with empty RemoteContext

2. **Model Redundancy:**
   - CoreDietaryCalorie (in CoreModels.swift) and DietaryCalorieRecord (in Records.swift) serve similar purposes
   - ✅ Now resolved with clear protocol definitions in Records.swift

3. **Broken/Incomplete Views:**
   - AppView shows three tabs but all point to SettingsView
   - Other view files incomplete or commented out

## Refactoring Plan

### Phase 1: Consolidate Data Models (Current Focus)
1. ✅ Define clear protocols for all model types
2. ✅ Implement protocols in SwiftData model classes
3. ✅ Add proper required initializers for SwiftData compatibility
4. ⬜ Remove duplicate CoreModels implementations
5. ⬜ Update service layer to use Records.swift models directly

### Phase 2: Fix Service Layer (Next Step)
1. ⬜ Update service references to use the consolidated models
2. ⬜ Simplify the query system
3. ⬜ Ensure proper data flow between models and services
4. ⬜ Verify unit tests pass

### Phase 3: Complete HealthKit Integration (Future)
1. ⬜ Re-enable HealthKit files
2. ⬜ Implement HealthKit integration
3. ⬜ Connect to RemoteContext properly
