import HealthKit
import SwiftData
import SwiftUI

/// A view that displays records of a specific type with source filtering.
struct CategoryView<T: HealthData>: View {
    @Environment(\.healthKit) private var healthKit: HealthKitService
    @DataQuery var records: [T]
    @State private var isAddingRecord = false

    private let dataModel: HealthDataModel
    private let uiDefinition: any HealthRecordUIDefinition

    init(_ dataModel: HealthDataModel) {
        self.dataModel = dataModel
        self.uiDefinition = dataModel.uiDefinition

        // Use the query method from HealthDataModel extension (no filtering at query level)
        let query: any HealthQuery<T> = dataModel.query()
        _records = DataQuery(
            query, from: .distantPast, to: .distantFuture
        )
    }

    var body: some View {
        mainContent
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
