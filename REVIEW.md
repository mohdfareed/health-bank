# HealthBank - Development Knowledge Base

## Architecture Overview
- **HealthKit**: Source-of-truth for externally generated metrics
- **SwiftData**: Local store for app-created entries
- **Data synchronization**: Combined from both sources when read
- **AppStorage**: User settings (units, themes)
- **Measurement API**: Unit conversions at view layer

## Pagination Implementation ✅ FIXED

### Critical Fix Completed:
**Fixed broken HealthKit pagination** that was causing exponentially expensive queries.

### Problem Identified:
The original implementation was using pseudo-offset pagination with HealthKit by:
1. Fetching `healthKitOffset + healthKitLimit` items from HealthKit (exponentially more data each page)
2. Dropping most data in memory with `dropFirst(healthKitOffset).prefix(healthKitLimit)`
3. This made page 1 fetch 50 items, page 2 fetch 100 items, page 3 fetch 150 items, etc.

### Solution Implemented:
**Cursor-based pagination for HealthKit** + **offset-based pagination for SwiftData**:

1. **DataService.swift**: Complete rewrite of pagination logic
   - **HealthKit**: Uses cursor-based pagination (calculates cursor from existing data)
   - **SwiftData**: Uses proper offset-based pagination with `localOffset`
   - Eliminated the expensive "fetch-all-then-drop" pattern
   - Each HealthKit query now only fetches exactly `pageSize` new items

2. **Key Changes**:
   - Removed `page` variable and `healthKitCursor` state - cursor calculated on-demand
   - Split loading into `loadLocalData()` and `loadRemoteData()` methods for clarity
   - **HealthKit cursor**: `data.filter({ $0.source != .local }).max(by: { $0.date < $1.date })`
   - **SwiftData offset**: `localOffset` tracks how many local items fetched
   - First HealthKit page: Query from `startDate` to `endDate` with `limit: pageSize`
   - Subsequent HealthKit pages: Query from `lastItemDate + 1ms` to `endDate` with `limit: pageSize`

3. **`hasMoreData` Logic Explained**:
   - `hasMoreData = newData.count >= pageSize`
   - **Why this works**: If a query returns fewer items than requested, it means we've reached the end
   - **Example**: If `pageSize = 50` but only 23 items returned, no more data exists
   - **Prevents unnecessary API calls**: Stops pagination automatically when data is exhausted
   - **Covers both sources**: Works for SwiftData (database exhausted) and HealthKit (no more samples)

3. **Performance Impact**:
   - Before: Page 3 would fetch 150 HealthKit items and drop 100 of them
   - After: Page 3 fetches exactly 50 new HealthKit items
   - Eliminates exponential memory and network usage growth

### Previously Completed:
1. **RecordsService.swift**: Added aggregated pagination state
2. **DataView.swift**: Explicit "Load More" button instead of automatic loading
3. **SettingsService.swift**: Fixed compilation error by removing `.biometrics` reference

### Architecture Notes:
- **HealthKit limitation**: No native offset support, only limit + date-based filtering
- **Cursor pattern**: More efficient for time-series data than offset-based pagination
- **Hybrid approach**: SwiftData (offset) + HealthKit (cursor) combined seamlessly

### Testing Status:
✅ Project builds successfully
✅ Critical pagination flaw identified and fixed
✅ HealthKit now uses proper cursor-based pagination
✅ Memory efficient - no more exponential data fetching
✅ **Initial data loading fixed** - Improved `reload()` for immediate UI feedback
⏳ Runtime testing needed to validate behavior

### Latest Fix: Cleaner Initial Data Loading
**Problem**: Data wasn't loading when first opening the page
**Root Cause**: Complex async state management in `reload()` method
**Better Solution**:
- **Synchronous data clearing**: `reload()` immediately empties data (instant UI feedback)
- **Asynchronous data loading**: Data loads in background after clearing
- **Simpler state management**: No extra flags or `autoLoad()` methods needed
- **Better async handling**: `.task()` instead of `.onAppear` for initial load

**Files Changed**:
- `DataService.swift`: Simplified `reload()` - immediate clear, async load
- `DataView.swift`: Changed from `.onAppear` to `.task()` for better async handling

### Next: Tab-Based Architecture
**Agreed Plan**: Switch from combined RecordsQuery to individual category tabs
- **Option C**: Separate `CategoryView<T>` for each record type
- **Benefits**: No pagination coordination needed, simpler logic, focused UX
- **Implementation**: After current fixes are validated
