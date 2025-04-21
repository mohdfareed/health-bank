import Foundation
import SwiftUI
import Testing

@testable import HealthTracker

struct AppTests {
    @Test func testAppBuild() async throws {
        print("Testing app...")
        let app = await MainApp()
        #expect((app as (any App)?) != nil)
        print(app)
    }

    // @Test func testCycleDaysAndRemainingDays() async throws {
    //     // Arrange: Create a WeeklyBudget with a reset day of Monday.
    //     let budget = WeeklyBudget(budget: 14000, resetDay: .monday)

    //     // Act: Retrieve cycleDays and remainingDays.
    //     let cycleDays = budget.cycleDays
    //     let remainingDays = budget.remainingDays

    //     // Assert: The sum should always equal 7.
    //     #expect(cycleDays + remainingDays == 7)
    // }

    // @Test func testResetDates() async throws {
    //     // Arrange: Create a WeeklyBudget with a reset day of Monday.
    //     let budget = WeeklyBudget(budget: 14000, resetDay: .monday)
    //     let calendar = Calendar.current

    //     // Act: Get the last reset and next reset dates.
    //     let lastReset = budget.lastResetDate
    //     let nextReset = budget.resetDate

    //     // Assert: The difference between lastReset and nextReset should be 7 days.
    //     let diff = calendar.dateComponents([.day], from: lastReset, to: nextReset).day!
    //     #expect(diff == 7)
    // }

    // @Test func testCalorieCalculations() async throws {
    //     // Arrange: Create a WeeklyBudget with a reset day of Monday.
    //     let budget = WeeklyBudget(budget: 14000, resetDay: .monday)
    //     let calendar = Calendar.current

    //     // Use the lastResetDate from the business logic as the anchor.
    //     let lastReset = budget.lastResetDate

    //     // Create calorie entries relative to the lastResetDate.
    //     // - Entry 1: 2000 calories consumed 1 day after the last reset.
    //     // - Entry 2: 1500 calories consumed 3 days after the last reset.
    //     // - Entry 3: 500 calories burned (negative) 2 days after the last reset.
    //     guard let entry1Date = calendar.date(byAdding: .day, value: 1, to: lastReset),
    //         let entry2Date = calendar.date(byAdding: .day, value: 3, to: lastReset),
    //         let entry3Date = calendar.date(byAdding: .day, value: 2, to: lastReset)
    //     else {
    //         throw NSError(domain: "Test", code: 1)
    //     }

    //     let entry1 = CalorieEntry(calories: 2000, date: entry1Date, source: .manual)
    //     let entry2 = CalorieEntry(calories: 1500, date: entry2Date, source: .manual)
    //     let entry3 = CalorieEntry(calories: -500, date: entry3Date, source: .manual)
    //     let entries = [entry1, entry2, entry3]

    //     // Act: Calculate consumed, remaining, and today's remaining calories.
    //     let consumed = budget.consumedCalories(for: entries)
    //     let remaining = budget.remainingCalories(for: entries)
    //     let remainingToday = budget.remainingDailyCalories(for: entries)

    //     // Assert:
    //     #expect(consumed == 3000)
    //     #expect(remaining == budget.budget - 3000)

    //     // Since remainingToday divides the remaining calories by the number of days left,
    //     // verify that it matches the expected average.
    //     #expect(remainingToday == remaining / budget.remainingDays)
    // }
}
