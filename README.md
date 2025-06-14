# HealthBank

HealthBank is an iOS application that takes a flexible, insight-driven approach to health tracking. Unlike traditional calorie counting apps that reset daily budgets, HealthBank uses **7-day running average budgeting** to provide a more realistic and sustainable approach to nutrition management.

## Core Philosophy

**7-Day Running Average Budgeting**: Your daily budget adjusts based on your 7-day average intake compared to your target. This transparent approach reflects how your body actually processes energy while giving you full agency over your choices.

**Maintenance Discovery & Deficit-Based Budgeting**: The app determines your actual calorie maintenance by analyzing the correlation between intake and weight changes. Users directly control their calorie deficit by adjusting their budget.

## Dashboard Card Design

**Card 1 - Budget Management:**
- Progress bar: Today's intake with two segments (base budget + adjustment)
- Display: Base remaining calories AND 7-day adjustment separately
- Action: Quick add calorie entry

**Card 2 - Maintenance Discovery:**
- Display: Budget vs estimated maintenance gap (e.g., "-300 cal deficit")
- Action: Quick add weight entry

## External Interactivity Framework Strategy

**App Intents (Core Interactive Framework):**
- "Log Calories" intent with calorie amount parameter
- "Log Weight" intent with weight parameter
- Automatically provides: Siri, Shortcuts, Spotlight, contextual suggestions
- Custom parameter validation and smart suggestions

**Interactive Widgets (Visual Interface):**

**Widget 1 - Budget Management:**
- Small: Adjusted remaining calories (e.g., "847 remaining")
- Medium: Base remaining + adjustment breakdown (e.g., "600 base + 247 surplus = 847 remaining")
- Large: Progress bar + interactive quick-add buttons (100, 200, 500 cal)

**Widget 2 - Maintenance Discovery:**
- Small: Budget vs maintenance gap (e.g., "-300 cal deficit")
- Medium: Gap + maintenance context (e.g., "-300 deficit (maintenance: 2200)")
- Large: Gap trend over recent days + quick weight log button

**Lock Screen Widgets:**
- Circular: Just remaining calories number
- Rectangular: Remaining calories + deficit/surplus indicator

**Future: Control Center Controls (iOS 18+):**
- Quick calorie logging from Control Center
- Toggle between preset amounts

**Philosophy:** Seamless means invisible until needed. Each widget mirrors its dashboard card functionality with quick logging capabilities.

## Design Decisions Needed
- Maintenance calculation algorithm
- Chart system for detailed historical views
- Widget update frequency and data freshness strategy
