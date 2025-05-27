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
- **`MeasurementField.swift`**: Plan to enhance for validation, computed value display, and editability control.
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
---
*This document is a concise summary. Detailed notes from specific reviews, workshops, and older plans are archived separately.*
