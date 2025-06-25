import Foundation
import Observation
import SwiftUI

// MARK: - Widget Data Repository
// ============================================================================

/// Observable repository for widget data with caching and automatic refresh
@Observable
public final class WidgetDataRepository: @unchecked Sendable {
    public static let shared = WidgetDataRepository()

    // MARK: - Published Data
    @MainActor private(set) var budgetData: BudgetData?
    @MainActor private(set) var macrosData: MacrosData?
    @MainActor private(set) var overviewData: OverviewData?
    @MainActor private(set) var isLoading: Bool = false
    @MainActor private(set) var lastRefresh: Date = .distantPast

    // MARK: - Cache Management
    private let cacheValidityDuration: TimeInterval = 300  // 5 minutes
    private var budgetDataCache: WidgetDataCache.CacheEntry<BudgetData>?
    private var macrosDataCache: WidgetDataCache.CacheEntry<MacrosData>?
    private var overviewDataCache: WidgetDataCache.CacheEntry<OverviewData>?

    // MARK: - Dependencies
    private let dataService = WidgetDataService.shared
    private let logger = AppLogger.new(for: WidgetDataRepository.self)

    // MARK: - Thread Safety
    private let queue = DispatchQueue(label: "WidgetDataRepository", qos: .utility)

    private init() {
        logger.info("WidgetDataRepository initialized")
    }

    // MARK: - Public Interface

    /// Refresh budget data if cache is stale
    @MainActor
    public func refreshBudgetData(with goals: UserGoals? = nil) async {
        await refreshBudgetDataIfNeeded(force: false)
    }

    /// Refresh macros data if cache is stale
    @MainActor
    public func refreshMacrosData(with goals: UserGoals? = nil) async {
        await refreshMacrosDataIfNeeded(force: false)
    }

    /// Refresh overview data if cache is stale
    @MainActor
    public func refreshOverviewData(with goals: UserGoals? = nil) async {
        await refreshOverviewDataIfNeeded(force: false)
    }

    /// Refresh all widget data if caches are stale
    @MainActor
    public func refreshAllData(with goals: UserGoals? = nil) async {
        await refreshBudgetDataIfNeeded(force: false)
        await refreshMacrosDataIfNeeded(force: false)
        await refreshOverviewDataIfNeeded(force: false)
    }

    /// Force refresh budget data regardless of cache state
    public func forceBudgetRefresh() async {
        await refreshBudgetDataIfNeeded(force: true)
    }

    /// Force refresh macros data regardless of cache state
    public func forceMacrosRefresh() async {
        await refreshMacrosDataIfNeeded(force: true)
    }

    /// Force refresh overview data
    public func forceRefreshOverviewData() async {
        await refreshOverviewDataIfNeeded(force: true)
    }

    /// Force refresh all widget data
    public func forceRefreshAllData() async {
        await refreshBudgetDataIfNeeded(force: true)
        await refreshMacrosDataIfNeeded(force: true)
        await refreshOverviewDataIfNeeded(force: true)
    }

    // MARK: - Cache Validation

    private var isBudgetDataValid: Bool {
        guard let cache = budgetDataCache else { return false }
        return cache.timestamp.timeIntervalSinceNow > -cacheValidityDuration
    }

    private var isMacrosDataValid: Bool {
        guard let cache = macrosDataCache else { return false }
        return cache.timestamp.timeIntervalSinceNow > -cacheValidityDuration
    }

    private var isOverviewDataValid: Bool {
        guard let cache = overviewDataCache else { return false }
        return cache.timestamp.timeIntervalSinceNow > -cacheValidityDuration
    }

    // MARK: - Private Implementation

    private func refreshBudgetDataIfNeeded(force: Bool, goals: UserGoals? = nil) async {
        // Check cache validity
        guard force || !isBudgetDataValid else {
            logger.debug("Budget data cache is still valid, skipping refresh")
            return
        }

        await MainActor.run {
            isLoading = true
        }

        do {
            if let newData = await dataService.fetchBudgetData() {
                queue.sync {
                    budgetDataCache = WidgetDataCache.CacheEntry(data: newData)
                }

                await MainActor.run {
                    budgetData = newData
                    lastRefresh = Date()
                }
                logger.debug("Budget data refreshed successfully")
            } else {
                logger.warning("Failed to fetch budget data")
            }
        }

        await MainActor.run {
            isLoading = false
        }
    }

    private func refreshMacrosDataIfNeeded(force: Bool, goals: UserGoals? = nil) async {
        // Check cache validity
        guard force || !isMacrosDataValid else {
            logger.debug("Macros data cache is still valid, skipping refresh")
            return
        }

        await MainActor.run {
            isLoading = true
        }

        do {
            if let newData = await dataService.fetchMacrosData() {
                queue.sync {
                    macrosDataCache = WidgetDataCache.CacheEntry(data: newData)
                }

                await MainActor.run {
                    macrosData = newData
                    lastRefresh = Date()
                }
                logger.debug("Macros data refreshed successfully")
            } else {
                logger.warning("Failed to fetch macros data")
            }
        }

        await MainActor.run {
            isLoading = false
        }
    }

    private func refreshOverviewDataIfNeeded(force: Bool, goals: UserGoals? = nil) async {
        // Check cache validity
        guard force || !isOverviewDataValid else {
            logger.debug("Overview data cache is still valid, skipping refresh")
            return
        }

        await MainActor.run {
            isLoading = true
        }

        do {
            if let newData = await dataService.fetchOverviewData() {
                queue.sync {
                    overviewDataCache = WidgetDataCache.CacheEntry(data: newData)
                }

                await MainActor.run {
                    overviewData = newData
                    lastRefresh = Date()
                }
                logger.debug("Overview data refreshed successfully")
            } else {
                logger.warning("Failed to fetch overview data")
            }
        }

        await MainActor.run {
            isLoading = false
        }
    }

    @MainActor
    private func setLoading(_ loading: Bool) {
        isLoading = loading
    }

    // MARK: - Direct Data Updates (for WidgetKit)

    /// Update budget data directly (for WidgetKit timeline entries)
    @MainActor
    public func updateBudgetData(_ data: BudgetData) {
        budgetData = data
        lastRefresh = Date()
    }

    /// Update macros data directly (for WidgetKit timeline entries)
    @MainActor
    public func updateMacrosData(_ data: MacrosData) {
        macrosData = data
        lastRefresh = Date()
    }

    /// Update overview data directly (for WidgetKit timeline entries)
    @MainActor
    public func updateOverviewData(_ data: OverviewData) {
        overviewData = data
        lastRefresh = Date()
    }

    // MARK: - Observer Integration

    /// Start observing HealthKit changes through the data service
    public func startObserving() {
        logger.info("Starting HealthKit observations")
        dataService.startObserving(repository: self)
    }

    /// Stop observing HealthKit changes
    public func stopObserving() {
        logger.info("Stopping HealthKit observations")
        dataService.stopObserving()
    }
}

// MARK: - Environment Integration
// ============================================================================

extension EnvironmentValues {
    @Entry public var widgetDataRepository: WidgetDataRepository = .shared
}

// MARK: - Mock Repository for WidgetKit
// ============================================================================

/// Mock repository for WidgetKit widgets to provide data without live data fetching
@Observable
public class MockWidgetDataRepository: @unchecked Sendable {
    @MainActor public private(set) var budgetData: BudgetData?
    @MainActor public private(set) var macrosData: MacrosData?
    @MainActor public private(set) var overviewData: OverviewData?
    @MainActor public private(set) var isLoading: Bool = false
    @MainActor public private(set) var lastUpdated: Date?

    public init(
        budgetData: BudgetData? = nil,
        macrosData: MacrosData? = nil,
        overviewData: OverviewData? = nil
    ) {
        Task { @MainActor in
            self.budgetData = budgetData
            self.macrosData = macrosData
            self.overviewData = overviewData
            self.lastUpdated = Date()
        }
    }

    public func refreshBudgetData(with goals: UserGoals) async {
        // No-op for mock
    }

    public func refreshMacrosData(with goals: UserGoals) async {
        // No-op for mock
    }

    public func refreshOverviewData(with goals: UserGoals) async {
        // No-op for mock
    }

    public func refreshAllData(with goals: UserGoals) async {
        // No-op for mock
    }
}
