# LLM Integration Instructions
Include these guidelines with every prompt to ensure consistent, high-quality contributions from the assistant.

Health Bank enables users to track and display health metrics—both from Apple HealthKit and local storage (with optional iCloud sync)—with live backup and configurable units.

## Guiding Principles
- **Simplicity**: Favor straightforward implementations; avoid unnecessary complexity.
- **Documentation**: Use self-explanatory code and only add concise comments where needed.
- **Testing**: Focus tests on critical functionality; keep test suite minimal and maintainable.

## Tech Stack
SwiftUI, SwiftData, AppStorage, HealthKit; project managed via XcodeGen, SPM, and Figma.

## Features & Scope
- Follow Apple best practices, official guidelines, and existing code conventions; prompt for approval before adopting any new conventions.
- Ensure all user-facing interactions include animations by default; disable explicitly when necessary (themes, global settings, view transitions).
- Support configurable units using Apple’s Measurement API: store all data in base units, display and input via user-selectable units (localized using latest Localization API); units configurable at view level.
- Read health metrics from both HealthKit and local storage; write updates to both with local storage (SwiftData) as the source of truth.

## Architecture & Data Flow

### Architecture
- Follow an MVVM-like structure:
  - Models: Define data structures and interfaces.
  - Services: Contain all logic and implementations.
  - Views: Handle UI via @State/@Binding (SwiftUI).

### Data & State Management
- Read health metrics from HealthKit and local SwiftData storage; write updates to both, with SwiftData as the source of truth.
- Share app-wide data via @Environment.
- Use AppStorage for user settings.

## Code Cleanup & Refactoring
- Adopt the latest SwiftUI APIs; replace deprecated patterns.
- Remove unused code and files immediately.
- Update the REVIEW.md file to reflect project structure and action items.

## Knowledge Base Usage
- Treat `REVIEW.md` as an engineer's personal wiki and to-do tracker for the project.
- Every time you explore or modify code, update `REVIEW.md` with:
  - Notes on key files and their purposes.
  - Observations, decisions, and areas needing follow-up.
  - Action items or TODOs organized as a concise list.
- Use this file as the primary reference for context when responding to prompts.

## Deep Guidance for Assistant

### Engineer’s Notebook Concept

Imagine an engineer joining a large codebase—every project restart is a blank slate. A top-tier engineer:
- Records notes on aspects they won’t remember.
- Logs thoughts, decisions, and plans.
- Maintains a concise to-do list.
- Builds a small knowledge base with file overviews, navigation tips, etc.
The assistant should treat `REVIEW.md` exactly this way.

### Conventions & Approval

- Strictly follow existing code conventions, Apple guidelines, and best practices.
- If proposing any new convention, ask for confirmation before using it.

### Animations by Default

- Always apply animations for UI changes (view transitions, theme toggles, global settings).
- Any disabled animation must be explicitly flagged.

### Data Flow & Units

- Read: Fetch metrics from HealthKit and local SwiftData.
- Write: Persist updates to both, with SwiftData as canonical source.
- Units:
  - Internally use base units.
  - Expose via Apple’s Measurement API.
  - Display/input via user-selectable dropdowns.
  - Localize formats using latest Localization API.
  - Allow per-view unit overrides.

### Localization & Strings

- Use Apple’s modern localization APIs for all user-facing text.
- All localized text should be defined in the `Views` layer.
- Initially focus on localizing units; extend as needed.

### When in Doubt

If the assistant ever deviates from these guidelines or introduces a new pattern, it should prompt for explicit approval.
