import SwiftData
import SwiftUI

// TODO: Remove icons from record row for category views.

/// A view that displays records of a specific type with source filtering.
struct CategoryView<T: HealthRecord>: View {
    @Environment(\.modelContext) private var context: ModelContext
    @DataQuery var records: [T]

    @State private var selectedSources: [DataSource] = []
    @State private var isAddingRecord = false
    @State private var isInitialized = false

    private let category: HealthRecordCategory
    private let query: any HealthQuery<T>

    private var filteredRecords: [T] {
        records.filter { record in
            if selectedSources.isEmpty {
                return true  // No filter applied, show all records
            }
            return selectedSources.contains(record.source)
        }
    }

    init(_ category: HealthRecordCategory) {
        self.category = category
        self.query = category.query()
        _records = DataQuery(
            query, from: .distantPast, to: .distantFuture, limit: 20
        )
    }

    var body: some View {
        List {
            ForEach(filteredRecords, id: \.id) { record in
                HealthRecordCategory.recordRow(record)
                    .swipeActions { swipeActions(for: record) }
            }
            loadMoreButton()
        }
        .navigationTitle(category.localized)
        .animation(.default, value: records)
        .animation(.default, value: selectedSources)
        .animation(.default, value: $records.isLoading)
        .animation(.default, value: $records.hasMoreData)

        .onAppear {
            Task {
                if !isInitialized {
                    isInitialized = true
                    await $records.load()
                }
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
            NavigationStack { category.recordSheet }
        }

        .onChange(of: isAddingRecord) { _, new in
            if !new {  // Refresh data when adding a new record
                Task { await $records.reload() }
            }
        }
    }

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            DataSourceFilterMenu($selectedSources)
        }

        ToolbarItem {
            Button("Add", systemImage: "plus") {
                isAddingRecord = true
            }
        }
    }

    @ViewBuilder private func loadMoreButton() -> some View {
        if $records.hasMoreData && !$records.isLoading {
            Button("Load More") {
                Task { await $records.load() }
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
        if record.source == .local {
            Button(role: .destructive) {
                context.delete(record)
                do {
                    try context.save()
                } catch {
                    AppLogger.new(for: T.self)
                        .error("Failed to save model: \(error)")
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // TODO: Add activity filters (record specific filters)
    /// A specialized filter menu for DataSource filtering.
    private struct DataSourceFilterMenu: View {
        @Binding var selected: [DataSource]

        init(_ selected: Binding<[DataSource]>) {
            self._selected = selected
        }

        var body: some View {
            Menu {
                ForEach(DataSource.allCases, id: \.self) { source in
                    Toggle(
                        isOn: Binding(
                            get: { selected.contains(source) },
                            set: {
                                if $0 {
                                    selected = [source]
                                } else {
                                    selected.removeAll { $0 == source }
                                }
                            }
                        )
                    ) {
                        Label {
                            Text(source.localized)
                        } icon: {
                            source.icon ?? Image.logo
                        }
                    }
                }

                Divider()
                Toggle(
                    isOn: Binding(
                        get: { selected.isEmpty },
                        set: { if $0 { selected = [] } }
                    )
                ) {
                    Text("All Sources")
                }
            } label: {
                Label(
                    "Filter", systemImage: "line.3.horizontal.decrease.circle"
                )
            }
        }
    }
}
