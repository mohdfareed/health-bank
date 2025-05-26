# Project Overview

Health Bank is an iOS application built with SwiftUI and SwiftData, integrated with Apple HealthKit to track and display user health metrics. It uses AppStorage for user preferences, Apple’s Measurement API for unit conversions, and XcodeGen/SPM for project management.

## Architecture & Data Flow

- **HealthKit**: Source-of-truth for externally generated metrics.
- **SwiftData**: Local store for app-created entries.
- **Synchronization**:
  - Data is combined from HealthKit and SwiftData when read.
  - All new data created within the app is stored in SwiftData and synchronized with HealthKit.
  - SwiftData is the source of truth for app-generated data.
- **AppStorage**: Manages user settings (units, themes) and is injected into views.
- **Measurement API**: Performs unit conversions at the views layer; all values stored internally in base units.

## Project Guidelines

- `Models/` contains data structures and protocols/interfaces.
- `Services/` contains implementations and business logic.
   - Services are about organizing related business logic
   - Services can be implemented as both objects and extension methods
- `Views/` handles the state and view logic.

- **ALWAYS** use the latest Swift features and APIs, updating any legacy code to modern standards.
- **ALWAYS** ensure that all aspects of a view are animated by default, unless explicitly stated otherwise.
- **ALWAYS** use reactive programming patterns to ensure the UI updates automatically when data changes.

## Core Assistant Guidelines

1. **Never Assume**
   If anything is unclear—requirements, style, context—pause and ask precise clarifying questions.

2. **Interrogate Requirements**
   Lead with questions that surface goals, constraints, edge cases, and success metrics before proposing solutions.

5. **Persistent Notes**
   Use `REVIEW.md` as your knowledge base of the project.
   Track decisions, style rules, requirements, rationales, etc. in this file.
   This is your permanent record of the project. It is your own notebook, not just a temporary scratchpad.
   It is not used by the user and for your use only.

6. **Self-Verification**
   When appropriate, include quick self-checks (e.g., sample inputs/outputs, minimal tests) to validate your proposals.

7. **Collaboration**
   Be concise and focused. Avoid unnecessary verbosity. Always keep the user in the loop with relevant context.
   The user is your collaborator; work together to solve problems.
