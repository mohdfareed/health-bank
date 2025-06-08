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

        // Use the query method from HealthDataModel extension
        let query: any HealthQuery<T>
        if dataModel == .activity, let filter = workoutFilter {
            query = ActivityQuery(workoutFilter: filter) as! any HealthQuery<T>
        } else {
            query = dataModel.query()
        }

        _records = DataQuery(
            query, from: .distantPast, to: .distantFuture
        )
    }

    init(_ dataModel: HealthDataModel, workoutFilters: Set<WorkoutActivity>) {
        self.dataModel = dataModel
        self.uiDefinition = dataModel.uiDefinition
        self.workoutFilter = nil
        self._selectedFilters = State(initialValue: workoutFilters)

        // Use the query method from HealthDataModel extension
        let query: any HealthQuery<T>
        if dataModel == .activity, !workoutFilters.isEmpty {
            query = ActivityQuery(workoutFilters: workoutFilters) as! any HealthQuery<T>
        } else {
            query = dataModel.query()
        }

        _records = DataQuery(
            query, from: .distantPast, to: .distantFuture
        )
    }

    var body: some View {
        // If selectedFilters differ from the initial state, show filtered view
        if dataModel == .activity && selectedFilters != (workoutFilter.map { Set([$0]) } ?? Set()) {
            CategoryView<T>(dataModel, workoutFilters: selectedFilters)
        } else {
            mainContent
        }
    }

    private var mainContent: some View {
        List {
            ForEach(records) { record in
                GenericRecordRow(record: record, dataModel: dataModel, uiDefinition: uiDefinition)
                    .swipeActions { swipeActions(for: record) }
            }
            loadMoreButton()
        }
        .navigationTitle(String(localized: uiDefinition.title))
        .animation(.default, value: $records.isLoading)
        .animation(.default, value: $records.isExhausted)
        .animation(.default, value: selectedFilters)

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
                            Image(systemName: selectedFilters.isEmpty ? "checkmark" : "")
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
                                Image(
                                    systemName: selectedFilters.contains(activity)
                                        ? "checkmark" : "")
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
        if !$records.isLoading && !$records.isExhausted {
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
                if record.source == .app {
                    Image.logo.asText
                        .foregroundColor(Color.accent)
                        .font(.caption2)
                }
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
