# Health Bank - Design Review & Key Decisions (Concise)

## 1. Project Vision & Scope
- **Objective**: iOS app for flexible health tracking (calories, macros, weight) using SwiftUI, SwiftData, HealthKit. Focus on aggregated data visualization and flexible time-based budgeting.
- **Target Users**: Developer, friends/family, health-conscious individuals.
- **Core Use Cases**: Flexible budget tracking, metric correlation, easy data logging, multi-platform access.

## 2. Core Architectural Pillars
- **UI**: SwiftUI.
- **App-Generated Data**: SwiftData (source of truth for app-created data).
- **External Data**: Apple HealthKit (source of truth for external data).
- **User Preferences**: AppStorage.
- **Unit Conversions**: Apple Measurement API. Internal storage in base units.

## 3. Guiding Design Principles
1.  **Minimize Coupling**: Explicit dependencies; separate data access (Providers) from logic (Services).
2.  **SwiftData Model Simplicity**: Models implement `DataRecord`; HealthKit conversion via extensions.
3.  **Focused Data Providers**: Generic `DataProvider` for CRUD; type-specific only if essential.
4.  **Pure Logic Services**: Services operate on passed data; grouped by functionality.
5.  **Use Standard Swift Types**: `ClosedRange<Date>`; services return simple types.
6.  **View Layer Responsibility**: Compose providers/services; transform data for display; access user preferences.

## 4. Data Flow & Synchronization
- **Reading**: Combined from HealthKit & SwiftData via `CombinedDataProvider`.
- **Creating**: SwiftData first, then queued for HealthKit sync. CloudKit for multi-device.
- (Detailed data flow diagrams exist separately).

## 5. Data Model & Provider Architecture
- `DataRecord` protocol for all health data. Models (`Weight`, `DietaryEnergy`, etc.) are SwiftData entities.
- `DataProvider` protocol for CRUD, with implementations for SwiftData, HealthKit, and a combined provider.
- (Conceptual diagrams for models and providers exist separately).

## 6. Service Layer Architecture
- Services organize business logic (e.g., `BudgetService`, `TrackerService`).
- Dynamic budget system: user-set targets, flexible period calculations.
- Services define their own return types; no generic shared visualization types in Models.
- (Conceptual service interaction diagrams exist separately).

## 7. Key Project Status & Next Steps (As of 2025-05-26)
- **Structure**: `Models/`, `Services/`, `Views/` in place. XcodeGen/SPM used.
- **Core Tech**: SwiftUI, SwiftData foundational elements exist.
- **Priorities**:
    1.  Implement `DataProvider` concrete classes (SwiftData, HealthKit).
    2.  Create/refine `UnitsService` (simplify if possible), `BudgetService`.
    3.  Develop core views, including `RecordView` (see section 9 for updated architecture).
    4.  Prioritize `async/await` for new asynchronous code.
    5.  Expand `AppError` for domain-specific errors.
    6.  Enhance `README.md` for new developers.
    7.  Establish and follow a concise testing strategy (XCTest, Swift Testing).

## 8. Animation & UI Polish
- **Principle**: UI changes should be animated by default using SwiftUI's native capabilities (e.g., `.animation()`, `withAnimation {}`).
- **Goal**: Achieve a polished, native feel adhering to Apple's HIG. Animations should be explicitly disabled only when necessary.
- **`DataRow.swift`**: Refactored for HIG alignment (text handling, layout, default animations).
- **`MeasurementField.swift`**: Plan to enhance for validation, computed value display, and edit-ability control.
- **`SettingsView.swift`**: Refactored to `NavigationStack`; plan for dedicated "Manage Calorie Budgets" screen.

## 9. New View: `RecordView` (Re-architected 2025-05-26)
- **Purpose**: A reusable SwiftUI view to display individual health records in a card-like format. Acts as a presentational component with state and logic managed by the parent view.
- **Key Features**:
    - Displays a title (passed as `LocalizedStringKey`) and an icon representing the data source (Local, HealthKit) from a `displayRecord` object.
    - Parent view injects content for model-specific fields and the date display/editing area via two `@ViewBuilder` closures: `fieldsContent(isEditing: Bool)` and `dateFooterContent(isEditing: Bool)`.
    - Parent view manages all editable state (e.g., using its own `@State` variables for field values).
    - Parent view controls `isInEditMode: Binding<Bool>`.
    - Parent view determines `canBeEdited: Bool` (e.g., if `record.source == .local`) and `hasChangesToSave: Bool`.
    - `RecordView` provides UI for Edit, Save, and Cancel buttons and invokes callbacks to the parent: `onEditButtonTapped`, `onSaveButtonTapped`, `onCancelButtonTapped`.
        - `onEditButtonTapped`: Parent should copy current record data to its editable state variables and set `isInEditMode = true`.
        - `onSaveButtonTapped`: Parent should create/update the record from its editable state variables, perform persistence, and set `isInEditMode = false`.
        - `onCancelButtonTapped`: Parent should set `isInEditMode = false` (and can optionally reset its editable state variables).
    - Data source icon and title are always read-only within the `RecordView` itself.
    - Design follows Apple HIG, utilizing project assets for icons/colors.
    - Animations for button transitions and mode changes are handled within `RecordView`.

## 10. General Guidelines from Reviews
- **`UnitsService`**: Re-evaluate for simplification. User preferences for measurement systems (Metric/US/UK) should be primary, with `Locale.current` as default.
- **Error Handling**: Use expanded `AppError` with nested types; clear propagation to UI.
- **Logging**: Continue `OSLog` via `AppLogger`.
- **Testing**: Focus on models, service logic, view models, and critical UI flows. Employ DI and mocking.

## 11. Views Architecture Review Session (2025-05-28)

### Session Objectives & Scope
- **Primary Concern**: Current Views/Core architecture doesn't follow Apple's SwiftUI best practices
- **Problem Areas**: Over-engineered, inconsistent, not reusable, will diverge as app grows
- **Focus**: Views/Core files and their usage in Views/Calories
- **Goal**: Redesign to follow Apple standards and create consistent, reusable patterns

### User Requirements Summary
1. **View Patterns Needed**:
   - Individual model record views supporting editing
   - Partial/custom views (e.g., calorie budget vs dietary calorie similarity)
   - Heterogeneous lists displaying different model types
   - Statistics/progress views that look similar to model displays
2. **Data Binding**: Prefers SwiftUI-native bindings with clone-and-replace pattern
3. **Editing Context**: Mixed approach - sometimes inline, sometimes modal/navigation
4. **Design Philosophy**: Follow Apple/SwiftUI intended patterns over custom abstractions
5. **Editability Constraint**: Only `.local` source records are editable (not HealthKit data)
6. **Additional Models**: `CalorieBudget` needs views but doesn't implement `DataRecord`

### Confirmed UX Pattern
**Two-Tier View System:**
1. **List Row Views**: Compact, read-only single row per model (all records)
2. **Detail Card Views**: Full display + editing capability (only for `.local` source records and `CalorieBudget`)

**Navigation Flow**: List Row → Tap → Detail Card (editable if `.local`, read-only if HealthKit)

### Current Architecture Analysis
**Key Models Identified:**
- Health Records: `Weight`, `DietaryEnergy`, `ActiveEnergy`, `RestingEnergy` (all implement `DataRecord`)
- Budget Model: `CalorieBudget` (singleton pattern)
- Services: `CaloriesService` provides business logic (macro calculations)

**Issues Identified:**
1. **Complex ViewModels**: `DataRowVM` and `MeasurementFieldVM` classes add unnecessary complexity
2. **State Management Problems**: Manual state synchronization in RecordView implementations
3. **Inconsistent Patterns**: Different views handle editing state differently
4. **Over-Engineering**: Too many abstractions for simple display components
5. **Tight Coupling**: Components are not easily reusable across different contexts
6. **Anti-SwiftUI Patterns**: Manual `.onChange` synchronization instead of reactive bindings

**Current Components:**
- `DataRow`: Generic row component with ViewModel pattern
- `MeasurementField`: Complex field with editing, units, computed values
- `RecordView`: Card-like display with edit functionality
- Calorie views: Repetitive implementations with manual state management

### Apple SwiftUI Best Practices Research
**The Apple Way (@Bindable + Direct Model Editing):**
1. **@Bindable**: For SwiftData/Observable objects, use `@Bindable var model: Model`
2. **Direct Binding**: `TextField("Name", text: $model.property)` - no intermediate state
3. **Automatic Persistence**: SwiftData automatically saves changes (no manual save logic)
4. **Simple Components**: Avoid ViewModels for display logic, use direct bindings

**Apple's Pattern Example:**
```swift
struct EditUserView: View {
    @Bindable var user: User  // SwiftData model
    var body: some View {
        Form {
            TextField("Name", text: $user.name)
            TextField("City", text: $user.city)
            DatePicker("Join Date", selection: $user.joinDate)
        }
    }
}
```

**Key Insights for Our Design:**
1. **No Clone-Replace Pattern Needed**: @Bindable with SwiftData provides automatic persistence
2. **Component Granularity**: Apple favors composable field-level components over complex containers
3. **Always-Editable**: Forms are always editable by default, no "edit mode" complexity

## 12. SwiftUI List Integration Requirements
- **Built-in List Editing**: Leverage SwiftUI's native `EditButton()`, `.onDelete()`, `.onMove()` patterns
- **Environment Integration**: Foundation components respect `@Environment(\.editMode)` automatically
- **No Custom Edit Logic**: Use SwiftUI's standard list editing instead of custom implementations

## 13. Component Interface Design (In Progress)

### Foundation Components (Building Blocks)
1. **MeasurementField<UnitType>**: Generic measurement input/display with automatic unit conversion from AppStorage
2. **CalorieField**: Specialized calorie display with optional macro breakdown support
3. **DateField**: Date selection with configurable precision (day/hour/minute)
4. **DataSourceIndicator**: Visual indicator for HealthKit vs Local data source

### Row Components (List Display)
- Compact single-line display for each model type
- Consistent tap gesture handling for navigation
- Built-in data source indicators
- Follows SwiftUI list editing patterns

### Card Components (Detail/Edit Views)
- Full field display using foundation components
- Direct @Bindable model binding (no ViewModels)
- Automatic SwiftData persistence
- Edit capability based on record.source == .local

### Usage Pattern Example
```swift
// Mixed list with different model types
List {
    CalorieBudgetRowView(budget: budget)
    ForEach(weightRecords) { WeightRowView(record: $0) }
    ForEach(calorieRecords) { DietaryEnergyRowView(record: $0) }
}

// Detail editing with direct binding
WeightCardView(record: $selectedWeight) // @Bindable auto-saves
```

### Next Steps
1. Define complete foundation component interfaces
2. Create visual architecture diagrams
3. Implement one complete example (Weight components)
4. Plan migration strategy from current Views/Core

## 13. Model Components Implementation Complete (2025-05-28)

### Successfully Implemented Components

**1. Weight Components (`WeightComponents.swift`)**
- `WeightRowView`: Compact list row using DataRow pattern
- `WeightCardView`: Expanded card with editing capabilities
- `WeightFormView`: Form for creating/editing weight records
- Proper LocalizedMeasurement integration with Weight.unit definition
- CardStyle modifier for consistent visual appearance

**2. Dietary Energy Components (`DietaryEnergyComponents.swift`)**
- `DietaryEnergyRowView`: List row with macro calculation display
- `DietaryEnergyCardView`: Card with macros breakdown support
- `DietaryEnergyFormView`: Form with optional macros entry
- `CalorieMacrosFormView`: Dedicated macros input form
- Integration with CaloriesService for macro calculations
- Dynamic macro validation and calculated calorie display

**3. Active Energy Components (`ActiveEnergyComponents.swift`)**
- `ActiveEnergyRowView`: List row with workout type and duration
- `ActiveEnergyCardView`: Card with workout details display
- `ActiveEnergyFormView`: Form with optional workout details
- `WorkoutDetailsFormView`: Dedicated workout type and duration form
- Duration formatting using Swift's Duration API
- WorkoutType localization support

**4. Calorie Budget Components (`CalorieBudgetComponents.swift`)**
- `CalorieBudgetRowView`: Compact budget display
- `CalorieBudgetFormView`: Budget form with macro calculations
- `CalorieBudgetCardView`: Card wrapper for budget forms
- Integration with macro calculation discrepancy detection
- Date picker for budget period selection

**5. Foundation Components (`FoundationComponents.swift`)**
- `DataSourceIndicator`: Visual indicator for HealthKit vs Local data
- Simplified to remove redundant custom components
- Proper integration with existing Assets.swift patterns

**6. Comprehensive Demo Views (`ModelComponentsDemoView.swift`)**
- `ModelComponentsDemoView`: List-based row component demonstration
- `ModelComponentsCardDemoView`: Card component showcase
- `ModelComponentsFormDemoView`: Form component examples
- Complete integration testing of all component types

### Technical Implementation Details

**Pattern Adherence:**
- All components follow existing DataRow + MeasurementField architecture
- Proper use of LocalizedMeasurement property wrapper
- CardStyle modifier for consistent visual appearance
- String(localized:) for all user-facing text
- Existing image and color system from Assets.swift

**Integration Points:**
- CaloriesService extension methods for macro calculations
- UnitDefinition usage for proper measurement handling
- DataSource enum for HealthKit vs Local distinction
- WorkoutType localization through Localization.swift patterns

**Error Resolution:**
- Fixed LocalizedMeasurement usage patterns
- Corrected DataRow content parameter requirements
- Resolved measurement formatting with proper unit conversions
- Fixed Binding vs Bool parameter type issues in MeasurementField

### Next Phase Opportunities

1. **Complete Migration Strategy** - Replace remaining Views/Core components systematically
2. **Integration Testing** - Validate components in actual app workflows
3. **Performance Optimization** - Review SwiftUI best practices implementation
4. **Visual Polish** - Enhance animations and micro-interactions
5. **Accessibility** - Add proper VoiceOver and accessibility support

### Architecture Benefits Achieved

- **Consistency**: All components follow identical patterns and conventions
- **Maintainability**: Leverages existing infrastructure instead of custom solutions
- **Scalability**: Easy to extend with additional model types
- **Integration**: Seamless interaction with existing services and data providers
- **User Experience**: Consistent visual language and interaction patterns

The component system now provides a complete foundation for health data visualization and editing, properly integrated with the existing codebase architecture.

## 14. Generic DataViews Solution (2025-05-29)

### Problem Addressed
The original `DataViews.swift` file had views tightly coupled to specific types (`DietaryEnergy`, `ActiveEnergy`, etc.), making it impossible to reuse calorie and macro views for other types like the `Budgets` class which also has calorie properties.

### Solution Implemented
**Generic Calorie and Macro Views**: Refactored the views to work with generic `Double?` values instead of specific model types, while maintaining backward compatibility.

#### Key Changes Made:

**1. Generic CaloriesRow**
```swift
// Works with any Double calorie value
CaloriesRow(
    calories: $budgets.calories,
    title: "Daily Calorie Budget",
    image: Image.dietaryCalorie,
    tint: .orange
)

// Still works with Calorie protocol types via convenience initializer
CaloriesRow(calorie: $dietaryEnergyRecord)
```

**2. Generic Macro Views**
```swift
// Direct usage with any Double? macro values
MacrosProteinRow(protein: $budgets.macros.protein)
MacrosCarbsRow(carbs: $budgets.macros.carbs)
MacrosFatRow(fat: $budgets.macros.fat)

// Convenience initializers for DietaryEnergy types
MacrosProteinRow(calorie: $dietaryEnergyRecord)
```

#### Usage Examples:

**With Budgets Class:**
```swift
Section(header: Text("Daily Budgets")) {
    CaloriesRow(calories: $budgets.calories, title: "Daily Calorie Budget")
    MacrosProteinRow(protein: $budgets.macros.protein)
    MacrosCarbsRow(carbs: $budgets.macros.carbs)
    MacrosFatRow(fat: $budgets.macros.fat)
}
```

**With DietaryEnergy (backward compatible):**
```swift
Section(header: Text("Food Entry")) {
    CaloriesRow(calorie: $dietaryEntry)
    MacrosProteinRow(calorie: $dietaryEntry)
    MacrosCarbsRow(calorie: $dietaryEntry)
    MacrosFatRow(calorie: $dietaryEntry)
}
```

### Technical Implementation
- **Primary Initializers**: Accept `Binding<Double?>` for maximum flexibility
- **Convenience Initializers**: Provide backward compatibility with existing model types
- **MeasurementRow Integration**: Maintains existing `LocalizedMeasurement` and unit conversion functionality
- **Computed Values**: Support for displaying calculated values (e.g., calories from macros)

### Benefits Achieved
1. **Reusability**: Views can now be used with any type that has calorie/macro properties
2. **Backward Compatibility**: Existing code continues to work unchanged
3. **Type Safety**: Maintains SwiftUI binding patterns and type safety
4. **Consistency**: Uses same visual styling and behavior across all contexts
5. **Maintainability**: Single source of truth for calorie/macro view implementations

This solution addresses the FIXME comment in the original code and enables flexible usage across different model types while preserving the existing component architecture.

## 15. Fixed Reactive Computed Fields (2025-05-30)

### Problem Identified
The computed fields in macro rows (protein, carbs, fat calculations) were not updating reactively when underlying macro values changed. The issue was in `MeasurementRow` where computed values were passed as function references instead of closures.

### Root Cause
- **Before**: `computed: calorie.calculatedProtein` (function reference)
- **Issue**: SwiftUI treated function references as static values, not tracking dependencies
- **Result**: Computed fields didn't update when underlying data changed

### Solution Implemented
Changed all computed parameters from function references to closures that execute within the view body:

**Updated Views:**
1. `CaloriesRow`: `computed: { (calorie as? DietaryCalorie)?.calculatedCalories() }`
2. `DietaryCaloriesRow`: `computed: { (calorie as? DietaryCalorie)?.calculatedCalories() }`
3. `MacrosProteinRow`: `computed: { calorie.calculatedProtein() }`
4. `MacrosCarbsRow`: `computed: { calorie.calculatedCarbs() }`
5. `MacrosFatRow`: `computed: { calorie.calculatedFat() }`

**MeasurementRow Signature:**
```swift
let computed: (() -> Double?)?
```

### Technical Details
- **Reactivity**: Closures execute during view body evaluation, allowing SwiftUI to track dependencies
- **Performance**: Closures are only executed when the view re-renders
- **Type Safety**: Maintained existing `(() -> Double?)?` signature for backward compatibility

### Impact
Now when a user edits any macro value (e.g., fat), the calculated values for other macros (e.g., protein, carbs) automatically update in the UI, providing real-time feedback during data entry.

## SwiftUI Reactivity Fix - Final Solution (2025-05-30)

### Root Cause Discovered
The real issue was in the binding identity, not dependency tracking. The `.casted()` method creates new binding objects each time it's called, breaking SwiftUI's object identity tracking between rows that should share the same data source.

### Final Solution
**Single Shared Binding in SettingsView.swift:**
```swift
var body: some View {
    // Create a single shared binding to ensure all rows track the same object
    let calorieBinding: Binding<DietaryCalorie> = $goals.calorieGoal.casted()

    Section(header: Text(String(localized: "Daily Calorie Budget"))) {
        DietaryCaloriesRow(calorie: calorieBinding.casted(), title: "Calories", showDate: false)
        MacrosProteinRow(calorie: calorieBinding, showDate: false)
        MacrosCarbsRow(calorie: calorieBinding, showDate: false)
        MacrosFatRow(calorie: calorieBinding, showDate: false)
    }
}
```

### Code Cleanup (2025-05-30)
Removed unnecessary complexity from DataViews.swift:
- **Removed**: Explicit dependency tracking with `let _ = calorie.macros.fat`
- **Removed**: `.id()` modifiers for forced view recreation
- **Kept**: Closure syntax for computed values (`computed: { calorie.calculatedProtein() }`)

### Key Insight
SwiftUI tracks dependencies based on binding object identity, not the underlying data. Multiple calls to `.casted()` created separate binding objects, preventing cross-row reactivity even when they pointed to the same data.

### Final State
- ✅ **SettingsView.swift**: Uses single shared binding for all macro rows
- ✅ **DataViews.swift**: Clean, simplified implementation with closure-based computed values
- ✅ **Views.swift**: MeasurementRow accepts closures for reactive computed fields

The solution is now both functional and maintainable, addressing the root cause rather than working around symptoms.
