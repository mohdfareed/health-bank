# LLM Integration Instructions

Health Bank enables users to track and display health metrics, both from Apple HealthKit and local storage (with optional iCloud sync).

## Guiding Principles

- **Simplicity**: Favor the simplest solution; avoid unnecessary complexity and abstraction.
- **Consistency**: Maintain uniformity in code style, naming conventions, and architecture.
- **Documentation**: Use self-explanatory code and only add concise comments where needed.
- **Testing**: Focus tests on critical functionality; keep test suite minimal and maintainable.
- **Standards**: Follow Apple best practices, official guidelines, and example code conventions; prompt for approval before adopting any new conventions.

## Tech Stack

SwiftUI, SwiftData, AppStorage, HealthKit; project managed via XcodeGen, SPM, and Figma.

## Architecture & Data Flow

### Architecture

- Follow an MVVM-like structure:
  - Models: Define data structures and interfaces. **No logic here.**
  - Services: Contain all logic and implementations. **No models here.**
  - Views: Handle UI via `@State`/`@Binding` (SwiftUI layer).
    - Everything visible to the user is defiend here, including user-facing text.

### Data & State Management

- Read health metrics from `HealthKit` and `SwiftData`.
- Write new data to both, with `SwiftData` as the canonical source.
  - `HealthKit` is the source of truth for health data created outside the app.
  - `SwiftData` is the source of truth for data created within the app.
- Use `AppStorage` for user settings, such as units and themes.

### Units & Localization

- Use Apple’s Measurement API for all unit conversions.
- Values are stored in base units internally.
- Values can be displayed by default according to user locale and preferences.
- Display unit can be overridden per view according to pre-defined supported units.

## Code Cleanup & Refactoring

1. Review the `REVIEW.md` file for context and existing notes.
2. Apply your changes.
3. Review the codebase as a whole for opportunities to simplify or improve code quality.
4. Adopt the latest SwiftUI APIs; replace deprecated patterns.
5. Ensure all changes are consistent with the existing code style and architecture.
6. Remove unused code and files.
7. Update the `REVIEW.md` file to reflect your

## Knowledge Base Usage

- Treat `REVIEW.md` as an engineer's personal wiki and to-do tracker for the project.
- Every time you explore or modify code, update `REVIEW.md` with:
  - Notes on key files and their purposes.
  - Observations, decisions, and areas needing follow-up.
  - Action items or TODOs organized as a concise list.
  - Reminders of user preferences or requests.
  - Anything you think might be useful to know in the future.
- Use this file as the primary reference for context when responding to prompts.
- Keep this file up-to-date with your latest understanding of the codebase.
- Clean up the file as you go, removing outdated or irrelevant notes.
- Ensure the file stays organized and easy to navigate. Do not let the file grow too large or unwieldy.
