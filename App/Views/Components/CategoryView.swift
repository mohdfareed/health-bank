import HealthKit
import SwiftData
import SwiftUI

/// A view that displays records of a specific type with source filtering.
struct CategoryView<T: HealthData>: View {
    @Environment(\.healthKit) private var healthKit: HealthKitService
    @DataQuery var records: [T]
    @State private var isAddingRecord = false
    @State private var selectedFilters: Set<WorkoutActivity> = []

    private let dataModel: HealthDataModel
    private let uiDefinition: any HealthRecordUIDefinition
    private let workoutFilter: WorkoutActivity?

    init(_ dataModel: HealthDataModel, workoutFilter: WorkoutActivity? = nil) {
        self.dataModel = dataModel
        self.uiDefinition = dataModel.uiDefinition
        self.workoutFilter = workoutFilter

        // Initialize selectedFilters based on workoutFilter
        if let filter = workoutFilter {
            self._selectedFilters = State(initialValue: Set([filter]))
        } else {
            self._selectedFilters = State(initialValue: Set())
        }

        // Use the query method from HealthDataModel extension (no filtering at query level)
        let query: any HealthQuery<T> = dataModel.query()
        _records = DataQuery(
            query, from: .distantPast, to: .distantFuture
        )
    }

    var body: some View {
        mainContent
    }

    private var filteredRecords: [T] {
        // If no filters are selected or this isn't activity data, return all records
        guard dataModel == .activity && !selectedFilters.isEmpty else {
            return records
        }

        // Filter records based on workout activity
        return records.filter { record in
            guard let activeEnergy = record as? ActiveEnergy,
                let workout = activeEnergy.workout
            else {
                return false
            }
            return selectedFilters.contains(workout)
        }
    }

    private var mainContent: some View {
        List {
            ForEach(filteredRecords) { record in
                GenericRecordRow(record: record, dataModel: dataModel, uiDefinition: uiDefinition)
                    .swipeActions { swipeActions(for: record) }
            }
            loadMoreButton()
        }
        .navigationTitle(String(localized: uiDefinition.title))
        .animation(.default, value: $records.isLoading)
        .animation(.default, value: $records.isExhausted)
        .animation(.default, value: selectedFilters)
        .animation(.default, value: filteredRecords.count)

        .onAppear {
            Task {
                await $records.loadNextPage()
            }
        }
        .refreshable {
            await $records.reload()
        }

        .toolbar {
            toolbar()
        }
        .toolbarTitleDisplayMode(.inline)

        .sheet(isPresented: $isAddingRecord) {
            NavigationStack {
                createRecordSheet()
            }
        }

        .onChange(of: isAddingRecord) { _, new in
            if !new {  // Refresh data when adding a new record
                Task { await $records.reload() }
            }
        }
    }

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        // Activity filter menu (only show for activity data)
        if dataModel == .activity {
            ToolbarItem(placement: .automatic) {
                Menu {
                    Button {
                        withAnimation {
                            selectedFilters.removeAll()
                        }
                    } label: {
                        Label {
                            Text("All Activities")
                        } icon: {
                            if selectedFilters.isEmpty {
                                Image(systemName: "checkmark")
                            }
                        }
                    }

                    Divider()

                    ForEach(WorkoutActivity.allCases, id: \.self) { activity in
                        Button {
                            withAnimation {
                                if selectedFilters.contains(activity) {
                                    selectedFilters.remove(activity)
                                } else {
                                    selectedFilters.insert(activity)
                                }
                            }
                        } label: {
                            Label {
                                Text(activity.localized)
                            } icon: {
                                if selectedFilters.contains(activity) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(
                        systemName: !selectedFilters.isEmpty
                            ? "line.3.horizontal.decrease.circle.fill"
                            : "line.3.horizontal.decrease.circle"
                    )
                    .foregroundStyle(Color.accent)
                }
                .animation(.default, value: selectedFilters)
            }
        }

        ToolbarItem {
            Button("Add", systemImage: "plus") {
                isAddingRecord = true
            }
        }
    }

    @ViewBuilder private func loadMoreButton() -> some View {
        // Only show load more button if we have unfiltered data available
        // and we're not filtering (or if we're filtering but have matching items)
        let hasFilteredItems = !filteredRecords.isEmpty
        let isFiltering = dataModel == .activity && !selectedFilters.isEmpty
        let showButton = !isFiltering || (isFiltering && hasFilteredItems)

        if !$records.isLoading && !$records.isExhausted && showButton {
            Button("Load More") {
                Task { await $records.loadNextPage() }
            }
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
        }

        if $records.isLoading {
            HStack {
                Spacer()
                ProgressView().scaleEffect(0.8)
                Spacer()
            }
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder private func swipeActions(for record: T) -> some View {
        if record.source == .app {
            Button(role: .destructive) {
                Task {
                    do {
                        let query: any HealthQuery<T> = dataModel.query()
                        try await query.delete(record, store: healthKit)
                        // Reload data after successful deletion
                        await $records.reload()
                    } catch {
                        let error = error.localizedDescription
                        AppLogger.new(for: Self.self).error(
                            "Failed to delete record: \(error)"
                        )
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    @ViewBuilder private func createRecordSheet() -> some View {
        dataModel.createNewRecordForm()
    }
}

/// A generic record row that works with any HealthRecordUIDefinition
private struct GenericRecordRow<T: HealthData>: View {
    let record: T
    let dataModel: HealthDataModel
    let uiDefinition: any HealthRecordUIDefinition

    var body: some View {
        NavigationLink {
            createEditRecordSheet()
        } label: {
            LabeledContent {
                record.source.icon.asText
                    .foregroundColor(Color.accent)
                    .font(.caption2)
            } label: {
                DetailedRow(image: nil, tint: nil) {
                    dataModel.createMainValue(record)
                } subtitle: {
                    dataModel.createRowSubtitle(record)
                        .textScale(.secondary)
                        .foregroundStyle(.secondary)
                } details: {
                    Text(
                        record.date.formatted(
                            date: .abbreviated, time: .shortened
                        )
                    )
                }
            }
        }
    }

    @ViewBuilder private func createEditRecordSheet() -> some View {
        dataModel.createEditRecordForm(record)
    }
}
