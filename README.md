# Health Bank

Health Bank is an iOS application designed for flexible and insightful health tracking. It allows users to monitor various health metrics such as calories (intake and expenditure), macro-nutrients (protein, carbohydrates, fat), and weight. The app integrates with Apple HealthKit to consolidate data from various sources and uses SwiftData for its local storage, ensuring that app-generated data is always available and synchronized.

Key features include aggregated data visualization and flexible time-based budgeting (e.g., weekly or custom periods rather than strict daily limits), catering to users who prefer a more adaptable approach to health management.

## Core Technologies

*   **UI**: SwiftUI
*   **App-Generated Data Storage**: SwiftData (primary source of truth for data created within the app)
*   **Externally-Generated Data**: Apple HealthKit (source of truth for data from other apps/devices)
*   **User Preferences**: AppStorage
*   **Project Management**: XcodeGen, Swift Package Manager (SPM)

## Getting Started

### Prerequisites

*   Xcode 16.0 or later (Swift 6.0)
*   An Apple Developer account (for HealthKit capabilities and team signing)

### Setup Instructions

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/your-username/health-bank.git
    cd health-bank
    ```

2.  **Set Up Environment Variables**:
    Create a `.env` file in the root of the project (`health-bank/.env`) with your Apple Developer Team ID:
    ```bash
    HEALTH_BANK_TEAM_ID=YOUR_TEAM_ID
    ```

3.  **Generate Xcode Project**:
    The project uses XcodeGen to generate the `.xcodeproj` file, which can be generated using:
    ```bash
    ./Scripts/setup.sh
    ```
## Project Structure

A brief overview of the main directories:

*   **`App/`**: Contains the core application code.
    *   **`Models/`**: SwiftData models, data protocols (e.g., `DataRecord`), and core types (e.g., `AppError`, `Settings`).
    *   **`Services/`**: Business logic, data management services, and utility services (e.g., `SettingsService`, `UnitsService`).
    *   **`Views/`**: SwiftUI views, view components, and related presentation logic.
*   **`Assets/`**: Asset catalogs for images, colors, icons, and localization strings.
*   **`Scripts/`**: Utility scripts for development (e.g., `setup.sh`).
*   **`Tests/`**: Unit tests (`AppTests/`) and UI tests (`UITests/`).
*   **`Project.yml`**: The XcodeGen project definition file.
*   **`Package.swift`**: Swift Package Manager manifest.
