import Foundation

// MARK: - Widget Data Models
// ============================================================================

/// Consolidated budget data for widgets
public struct BudgetData: Sendable, Equatable {
    public let calories: CalorieData
    public let weight: WeightData
    public let budget: Double?
    public let remaining: Double?
    public let credit: Double?
    public let date: Date
    public let isValid: Bool

    public init(
        calories: CalorieData,
        weight: WeightData,
        budget: Double?,
        remaining: Double?,
        credit: Double?,
        date: Date = Date()
    ) {
        self.calories = calories
        self.weight = weight
        self.budget = budget
        self.remaining = remaining
        self.credit = credit
        self.date = date
        self.isValid = calories.isValid && weight.isValid && budget != nil
    }
}

/// Calorie intake data
public struct CalorieData: Sendable, Equatable {
    public let currentIntake: Double?
    public let smoothedIntake: Double?
    public let isValid: Bool

    public init(
        currentIntake: Double?,
        smoothedIntake: Double?,
        isValid: Bool = true
    ) {
        self.currentIntake = currentIntake
        self.smoothedIntake = smoothedIntake
        self.isValid = isValid && currentIntake != nil
    }
}

/// Weight and maintenance data
public struct WeightData: Sendable, Equatable {
    public let current: Double?
    public let maintenance: Double?
    public let weightSlope: Double
    public let isValid: Bool

    public init(
        current: Double?,
        maintenance: Double?,
        weightSlope: Double,
        isValid: Bool = true
    ) {
        self.current = current
        self.maintenance = maintenance
        self.weightSlope = weightSlope
        self.isValid = isValid && maintenance != nil
    }
}

/// Macro nutrients data for widgets
public struct MacrosData: Sendable, Equatable {
    public let budget: BudgetData
    public let protein: MacroNutrient
    public let carbs: MacroNutrient
    public let fat: MacroNutrient
    public let date: Date
    public let isValid: Bool

    public init(
        budget: BudgetData,
        protein: MacroNutrient,
        carbs: MacroNutrient,
        fat: MacroNutrient,
        date: Date = Date()
    ) {
        self.budget = budget
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
        self.isValid = budget.isValid && protein.isValid && carbs.isValid && fat.isValid
    }
}

/// Individual macro nutrient data
public struct MacroNutrient: Sendable, Equatable {
    public let currentIntake: Double?
    public let smoothedIntake: Double?
    public let baseBudget: Double?
    public let adjustedBudget: Double?
    public let remaining: Double?
    public let credit: Double?
    public let isValid: Bool

    public init(
        currentIntake: Double?,
        smoothedIntake: Double?,
        baseBudget: Double?,
        adjustedBudget: Double?,
        remaining: Double?,
        credit: Double?
    ) {
        self.currentIntake = currentIntake
        self.smoothedIntake = smoothedIntake
        self.baseBudget = baseBudget
        self.adjustedBudget = adjustedBudget
        self.remaining = remaining
        self.credit = credit
        self.isValid = currentIntake != nil && baseBudget != nil
    }
}

/// Overview data combining budget and macros for detailed analysis
public struct OverviewData: Sendable, Equatable {
    public let budget: BudgetData
    public let macros: MacrosData
    public let trends: TrendData?
    public let calibrationStatus: CalibrationStatus
    public let date: Date
    public let isValid: Bool

    public init(
        budget: BudgetData, macros: MacrosData, trends: TrendData?,
        calibrationStatus: CalibrationStatus, date: Date = Date()
    ) {
        self.budget = budget
        self.macros = macros
        self.trends = trends
        self.calibrationStatus = calibrationStatus
        self.date = date
        self.isValid = budget.isValid && macros.isValid
    }
}

/// Trend analysis data
public struct TrendData: Sendable, Equatable {
    public let weightTrend: Double?  // kg/week
    public let calorieTrend: Double?  // kcal/day average
    public let validPeriod: Int  // days of valid data

    public init(weightTrend: Double?, calorieTrend: Double?, validPeriod: Int) {
        self.weightTrend = weightTrend
        self.calorieTrend = calorieTrend
        self.validPeriod = validPeriod
    }
}

/// Calibration status for maintenance calculations
public struct CalibrationStatus: Sendable, Equatable {
    public let isWeightValid: Bool
    public let isCalorieValid: Bool
    public let daysOfData: Int
    public let requiredDays: Int

    public init(isWeightValid: Bool, isCalorieValid: Bool, daysOfData: Int, requiredDays: Int = 14)
    {
        self.isWeightValid = isWeightValid
        self.isCalorieValid = isCalorieValid
        self.daysOfData = daysOfData
        self.requiredDays = requiredDays
    }

    public var isCalibrated: Bool {
        isWeightValid && isCalorieValid
    }

    public var calibrationProgress: Double {
        min(Double(daysOfData) / Double(requiredDays), 1.0)
    }
}

// MARK: - Widget Data Cache
// ============================================================================

/// Cache configuration for widget data
public struct WidgetDataCache {
    public static let defaultCacheValidityDuration: TimeInterval = 300  // 5 minutes

    public struct CacheEntry<T: Sendable> {
        public let data: T
        public let timestamp: Date
        public let validityDuration: TimeInterval

        public var isValid: Bool {
            timestamp.addingTimeInterval(validityDuration) > Date()
        }

        public init(data: T, validityDuration: TimeInterval = defaultCacheValidityDuration) {
            self.data = data
            self.timestamp = Date()
            self.validityDuration = validityDuration
        }
    }
}
