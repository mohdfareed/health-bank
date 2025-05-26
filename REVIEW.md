# Health Bank - Design Review & Key Decisions

## 1. Project Vision & Scope
- **Objective**: iOS app for flexible health tracking (calories, macros, weight) using SwiftUI, SwiftData, and HealthKit. Focus on aggregated data visualization and flexible time-based budgeting (e.g., weekly/custom vs. strict daily).
- **Target Users**: Developer (primary), close friends/family, and other health-conscious individuals seeking alternatives to daily-only tracking.
- **Initial Scope (v1)**:
    - Track calories (intake and expenditure).
    - Track macro-nutrients (protein, carbs, fat) as a breakdown of calories.
    - Track weight for correlation with caloric data.
    - Visualize these metrics across user-defined flexible time periods.
- **Core Use Cases**: Flexible budget tracking, metric correlation visualization, easy data logging, multi-platform access (widgets, Watch, shortcuts).

## 2. Core Architectural Pillars
- **UI**: SwiftUI.
- **App-Generated Data Storage**: SwiftData (primary source of truth for data created within the app).
- **Externally-Generated Data**: Apple HealthKit (source of truth for data from other apps/devices).
- **User Preferences**: AppStorage (for settings like units, themes).
- **Unit Conversions**: Apple's Measurement API, managed by a dedicated `UnitsService`. All data stored internally in standardized base units.

## 3. Guiding Design Principles
1.  **Minimize Coupling**:
    - Separate data access (Providers) from business logic (Services).
    - Services should ideally be pure functions (input -> output).
    - Dependencies should be explicit, not implicitly fetched.
2.  **SwiftData Model Simplicity**:
    - SwiftData models directly implement the `DataRecord` protocol.
    - Avoid intermediary abstraction layers between domain and persistence models.
    - HealthKit conversion logic handled via extensions on the models themselves.
3.  **Focused Data Providers**:
    - A generic `DataProvider` protocol for standard CRUD operations.
    - Providers are responsible for data access only, not business logic.
    - Specialized, type-specific provider protocols only if essential.
4.  **Pure Logic Services**:
    - Services encapsulate business logic and operate on data passed to them (not self-fetching).
    - Group services by functionality (e.g., budgeting, unit conversion), not by data type.
    - Services should not make assumptions about how data will be visualized.
    - Can be objects or collections of extension methods; logical organization is key.
5.  **Use Standard Swift Types**:
    - Employ `ClosedRange<Date>` directly for date ranges (replacing custom `TimeFrame` type).
    - Services return simple arrays, dictionaries, and standard Swift types rather than custom shared visualization types.
    - Avoid enforcing specific time granularity (daily, weekly) in service interfaces; let services or views decide.
6.  **View Layer Responsibility**:
    - Views compose providers and services to fetch and display data.
    - Handle transformation of data into visual formats.
    - Access user preferences for display options (units, etc.).

## 4. Data Flow & Synchronization
- **Reading Data**: Combined from both HealthKit and SwiftData sources by a `CombinedDataProvider`.
- **Creating Data**: New data is written to SwiftData first. Changes trigger an event queue for subsequent synchronization to HealthKit by a `HealthKit Sync Service`.
- **Multi-Device Synchronization**: SwiftData changes sync to other user devices via CloudKit.
- **Sources of Truth**: SwiftData for app-generated data; HealthKit for externally-generated data.
- **Diagram**:
    ```mermaid
    flowchart TD
        User[User] --> |Enters Data| App[Health Bank App]
        App --> |Writes| SD[SwiftData]
        SD --> |Syncs via CloudKit| SD2[SwiftData on Other Devices]
        SD --> |Triggers| Events[Event Queue]
        Events --> |Processed by| Sync[HealthKit Sync Service]
        Sync --> |Writes| HK[HealthKit]
        HK --> |Reads| Reader[Data Provider Layer]
        SD --> |Reads| Reader
        Reader --> |Combined Data| Views[UI Views]
        ExternalApps[External Health Apps] --> |Write| HK
    ```

## 5. Data Model & Provider Architecture
- **`DataRecord` Protocol**: Base protocol for all health data, defining `date: Date` and `source: DataSource`.
- **SwiftData Models**:
    - `WeightRecord`, `DietaryCalorieRecord`, `BurnedCalorieRecord`, `WorkoutRecord`.
    - Each model directly implements `DataRecord`.
    - Include static `fromHealthKit(...)` and instance `toHealthKitSample()` methods for HealthKit conversion.
- **`DataProvider` Protocol**: Defines generic `fetch`, `store`, and `delete` methods using `AnyPublisher`.
    - Implementations: `SwiftDataProvider`, `HealthKitProvider`.
    - `CombinedDataProvider`: Aggregates data from multiple providers.
- **Diagrams (Conceptual)**:
    ```mermaid
    classDiagram
        class DataRecord {
            <<protocol>>
            +date: Date
            +source: DataSource
        }
        class WeightRecord { <<SwiftData Model>> }
        class DietaryCalorieRecord { <<SwiftData Model>> }
        class BurnedCalorieRecord { <<SwiftData Model>> }
        class WorkoutRecord { <<SwiftData Model>> }
        DataRecord <|.. WeightRecord
        DataRecord <|.. DietaryCalorieRecord
        DataRecord <|.. BurnedCalorieRecord
        DataRecord <|.. WorkoutRecord
    ```
    ```mermaid
    classDiagram
        class DataProvider {
            <<protocol>>
            +fetch() AnyPublisher
            +store() AnyPublisher
            +delete() AnyPublisher
        }
        class SwiftDataProvider
        class HealthKitProvider
        class CombinedDataProvider {
            -providers: [DataProvider]
        }
        DataProvider <|.. SwiftDataProvider
        DataProvider <|.. HealthKitProvider
        DataProvider <|.. CombinedDataProvider
    ```

## 6. Service Layer Architecture
- **Concept**: Services organize related business logic. They can be implemented as traditional objects or as collections of extension methods. The key is logical grouping and adherence to "Pure Logic Services" principle.
- **Key Services (Examples)**:
    - `BudgetService` (e.g., `CalorieBudgetService`, `MacroBudgetService`):
        - Calculates target amounts for timeframes.
        - Tracks current usage.
        - Provides daily breakdowns and remaining budget projections.
    - `TrackerService` (e.g., `WeightTrackerService`):
        - Fetches data points for visualization over time.
        - Calculates relevant statistics (e.g., average, min, max).
    - `UnitsService`: Manages all unit conversion logic and user preferences for units.
- **Dynamic Budget System**:
    1. User sets daily target values in settings.
    2. Budget service calculates total budget for a selected flexible time period (daily, weekly, monthly).
    3. Dynamically redistributes remaining budget over the rest of the period if consumption varies.
- **Service-Specific Data Structures**: Services define their own return types suitable for their functionality. Generic visualization types (like `DataPoint`, `Statistics`) are not shared in the Models layer to avoid premature standardization and maintain flexibility. Time-based grouping (daily, weekly) is determined by each service as appropriate.
- **Diagram (Conceptual Service Interaction)**:
    ```mermaid
    classDiagram
        class UserSettings {
            +getBudgetSetting()
            +getPreferredUnits()
        }
        class BudgetService {
            <<protocol>>
            +getTargetAmount()
            +getCurrentUsage()
        }
        class CalorieBudgetService {
            -dataProvider: DataProvider
            -userSettings: UserSettings
        }
        class TrackerService {
            <<protocol>>
            +getDataPoints()
            +getStatistics()
        }
        class WeightTrackerService {
            -dataProvider: DataProvider
        }
        BudgetService <|.. CalorieBudgetService
        TrackerService <|.. WeightTrackerService
    ```

## 7. Units Management Strategy
- **Storage**: All data stored in standardized base units in SwiftData (e.g., grams for macros, respecting HealthKit's unit system when interacting with it).
- **`UnitsService`**: A dedicated service manages all unit conversion logic, handles domain-specific conventions (e.g., calories always kcal), and supports user overrides for preferred display units.
- **Presentation Layer**: Views request data with desired units, defaulting to user's locale-based preferences or context-specific units.
- **Conventions**: Calories (kcal), Macro-nutrients (grams), Weight (locale-dependent: kg/lbs), Distance (locale-dependent: km/miles).

## 8. Key Design Challenges Addressed
The architecture and design principles aim to address:
- **Unified Data Access**: Via `CombinedDataProvider`.
- **Reactive Updates**: Leveraging Combine publishers from providers and services.
- **Flexible Visualization Components**: By services providing adaptable data structures.
- **User Settings & Units Management**: Through `AppStorage` and a dedicated `UnitsService`.

## 9. File Structure (Current Plan)
- **`App/Models/`**:
    - `DataRecord.swift` (Core protocol, `DataSource` enum)
    - `DataProvider.swift` (Provider protocols and `CombinedDataProvider`)
    - `Calorie.swift`, `Weight.swift`, `Workout.swift` (Domain-specific protocols and SwiftData models)
- **`App/Services/`**:
    - `BudgetService.swift`, `TrackerService.swift`, `UnitsService.swift` (Service protocols and implementations/extensions)
- **Principles**: Files named after primary type/concept; related functionality grouped; clear separation of protocols/implementations.

## 10. Implementation Strategy & Action Plan (v1)

### v1 Feature Focus:
1.  **Core Metrics**: Calories (dietary & burned), Macro-nutrients, Weight.
2.  **Data Layer**: SwiftData models implementing `DataRecord`, basic HealthKit integration.
3.  **Visualization**: Budget view with daily breakdown, basic timeline charts, simple dashboard.
4.  **User Settings**: Daily budget targets, preferred time periods, basic unit preferences.

### Action Plan Phases:
1.  **Core Infrastructure (Current Focus)**:
    - [x] Define base protocol (`DataRecord`).
    - [~] Create SwiftData models for health metrics (largely complete).
    - [ ] Implement `DataProvider` protocol and `SwiftDataProvider` concrete type.
    - [ ] Set up basic `HealthKitProvider`.
    - [ ] Implement `CombinedDataProvider`.
2.  **Services Layer**:
    - [~] Define service protocols (initial versions exist).
    - [ ] Implement `BudgetService` for calories and macros.
    - [ ] Create `TrackerService` for weight.
    - [ ] Add user settings management (`AppStorage` based).
    - [ ] Set up `UnitsService`.
3.  **UI Components**:
    - [ ] Develop budget visualization view.
    - [ ] Create timeline chart component.
    - [ ] Build basic dashboard.
    - [ ] Design data input screens.
4.  **Polish & Launch**:
    - [ ] Add animations and transitions.
    - [ ] Implement widget support.
    - [ ] Test across different devices.
    - [ ] Finalize settings and preferences.

## 11. Cleanup Tasks (Derived from Design Principles)
1.  **Remove or Redesign**:
    - `TimeFrame.swift`: Replace usage with `ClosedRange<Date>`. Date range utilities to become extension methods, possibly organized in `Services/DateUtilities.swift` or similar.
    - `VisualizationTypes.swift` (e.g., `DataPoint`, `Statistics` from Models): Services will define their own specific return types.
    - Review current service protocols to ensure they align with "Pure Logic Services" principle (taking input, returning output, no direct data fetching within the service itself).
2.  **Keep and Refine**:
    - `DataRecord.swift`: Core protocol is sound.
    - `DataProvider.swift`: Ensure methods consistently return `AnyPublisher`.
    - Model implementations (`Calorie.swift`, `Weight.swift`, etc.): Ensure HealthKit conversion extensions are robust.

## 12. Open Questions & Future Considerations
- Strategy for handling historical data import/sync when HealthKit access is granted post-initial setup.
- Optimal UX for setting up and managing budgets for multiple, potentially related, metrics.
- Desired granularity for time period selection in the UI (e.g., specific day counts, week/month pickers).

## 13. Medical Rationale for Flexible Budgeting
The approach of weekly or flexible caloric budgeting, as opposed to strict daily limits, is supported by nutritional science. The human body responds to energy balance over extended periods, not requiring exact daily consistency. This flexibility can be psychologically healthier, allowing for natural variations in appetite and activity while still supporting overall health goals.
