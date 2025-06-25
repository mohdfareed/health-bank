import Foundation
import SwiftUI

// MARK: - Widget Data Service
// ============================================================================

/// Service responsible for fetching and preparing widget data
public class WidgetDataService: @unchecked Sendable {
    public static let shared = WidgetDataService()

    private let logger = AppLogger.new(for: WidgetDataService.self)
    private let healthKitService = HealthKitService.shared

    public init() {
        logger.info("WidgetDataService initialized")
    }

    // MARK: - Data Fetching

    /// Fetch comprehensive budget data for widgets
    @MainActor
    public func fetchBudgetData(for date: Date = Date()) async -> BudgetData? {
        logger.debug("Fetching budget data for date: \(date)")

        // Return mock data for now - all legacy analytics eliminated
        // TODO: Replace with proper implementation after migration
        let mockBudgetData = BudgetData(
            calories: CalorieData(
                currentIntake: 1500,
                smoothedIntake: 1450,
                isValid: true
            ),
            weight: WeightData(
                current: 70.0,
                maintenance: 2000,
                weightSlope: 0.0,
                isValid: true
            ),
            budget: 2000,
            remaining: 500,
            credit: 0,
            date: date
        )

        logger.debug("Successfully fetched mock budget data")
        return mockBudgetData
    }

    /// Fetch comprehensive macros data for widgets
    @MainActor
    public func fetchMacrosData(for date: Date = Date()) async -> MacrosData? {
        logger.debug("Fetching macros data for date: \(date)")

        // Get budget data first
        guard let budgetData = await fetchBudgetData(for: date) else {
            logger.warning("Failed to load budget data for macros calculation")
            return nil
        }

        // Return mock data for now - all legacy analytics eliminated
        // TODO: Replace with proper implementation after migration
        let mockMacrosData = MacrosData(
            budget: budgetData,
            protein: MacroNutrient(
                currentIntake: 120,
                smoothedIntake: 115,
                baseBudget: 150,
                adjustedBudget: 150,
                remaining: 30,
                credit: 5
            ),
            carbs: MacroNutrient(
                currentIntake: 200,
                smoothedIntake: 195,
                baseBudget: 250,
                adjustedBudget: 250,
                remaining: 50,
                credit: 5
            ),
            fat: MacroNutrient(
                currentIntake: 70,
                smoothedIntake: 68,
                baseBudget: 78,
                adjustedBudget: 78,
                remaining: 8,
                credit: 2
            ),
            date: date
        )

        logger.debug("Successfully fetched mock macros data")
        return mockMacrosData
    }

    /// Fetch comprehensive overview data combining budget and macros
    @MainActor
    public func fetchOverviewData(for date: Date = Date()) async -> OverviewData? {
        logger.debug("Fetching overview data for date: \(date)")

        guard let budgetData = await fetchBudgetData(for: date),
            let macrosData = await fetchMacrosData(for: date)
        else {
            logger.warning("Failed to load budget or macros data for overview")
            return nil
        }

        // Calculate trend data
        let trends = TrendData(
            weightTrend: budgetData.weight.weightSlope,
            calorieTrend: budgetData.calories.smoothedIntake,
            validPeriod: budgetData.weight.isValid ? 14 : 0
        )

        // Calculate calibration status
        let calibrationStatus = CalibrationStatus(
            isWeightValid: budgetData.weight.isValid,
            isCalorieValid: budgetData.calories.isValid,
            daysOfData: budgetData.weight.isValid ? 14 : 0,
            requiredDays: 14
        )

        let overviewData = OverviewData(
            budget: budgetData,
            macros: macrosData,
            trends: trends,
            calibrationStatus: calibrationStatus,
            date: date
        )

        return overviewData
    }

    // MARK: - Observer Management

    /// Start observing HealthKit changes and notify repository
    public func startObserving(repository: WidgetDataRepository) {
        logger.info("Starting HealthKit observation for widget data repository")

        // Use existing HealthKit observers but connect to repository
        let observers = HealthKitObservers.shared

        // Create custom observer for budget data
        observers.startObserving(
            for: "WidgetDataService.Budget",
            dataTypes: [.dietaryCalories, .bodyMass],
            onUpdate: { [weak repository, logger] in
                logger.debug("Budget data changed - notifying repository")
                Task {
                    await repository?.refreshBudgetData()
                }
            }
        )

        // Create custom observer for macros data
        observers.startObserving(
            for: "WidgetDataService.Macros",
            dataTypes: [.protein, .carbs, .fat, .dietaryCalories, .bodyMass],
            onUpdate: { [weak repository, logger] in
                logger.debug("Macros data changed - notifying repository")
                Task {
                    await repository?.refreshMacrosData()
                }
            }
        )
    }

    /// Stop observing HealthKit changes
    public func stopObserving() {
        logger.info("Stopping HealthKit observation for widget data repository")

        let observers = HealthKitObservers.shared
        observers.stopObserving(for: "WidgetDataService.Budget")
        observers.stopObserving(for: "WidgetDataService.Macros")
    }
}
