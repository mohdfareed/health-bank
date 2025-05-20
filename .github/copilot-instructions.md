# Health Bank Refactoring Instructions

## Project Overview

Health Bank is an iOS health tracking app with the following core requirements:

- Allow users to track health metrics
- Display data from Apple HealthKit
- Display data stored locally (support togglable iCloud sync)
- Sync local data with Apple HealthKit (live backup)
- Support changing the display units of the data

## Core Principles

- **Simplicity**: Keep the codebase simple and easy to understand. Avoid complexity at all costs.
- **Documentation**: Make documentation concise. Rely on self-documenting code when possible.
- **Testing**: Only test what is necessary. Keep tests to a minimal, with a focus on critical paths.

## Technologies

- SwiftUI
- SwiftData
- AppStorage
- HealthKit

**Project:**

- XcodeGen
- SPM
- Figma

## Requirements

- Use best practices for SwiftUI, using the architecture:
    - `Models` - Interfaces and data models
    - `Services` - Business logic
    - `Views` - UI components
- Use `Views` as what is conventionally called `ViewModels` in MVVM, such that:
    - `Views` are responsible for querying, connecting services, and updating the UI (and animations)
    - There should be a core UI library that defines the building blocks that are used by the views
- Use `Services` to hold all logic and implementations
- Use `Models` to define the data structures and interfaces

**General guidelines:**

- Use `AppStorage` for all settings
- Use `SwiftData` for all data models (all HealthKit data can be stored locally)
- Use `HealthKit` for only the data it supports
- Ensure all code supports animations and live updates through `@State` and `@Binding`
- Use `@Environment` for all data that is shared across the app
- Use the latest SwiftUI features and API
