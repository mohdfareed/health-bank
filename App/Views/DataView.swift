import SwiftData
import SwiftUI

// MARK: Health Data View
// ============================================================================

struct HealthDataView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var isAddingRecord = false
    @State private var selectedCategory: HealthRecordCategory = .dietary

    var body: some View {
        NavigationStack {
            AdaptiveGridContainer {
                ForEach(
                    HealthRecordCategory.allCases, id: \.self
                ) { category in
                    HealthGridItem(
                        title: category.localized,
                        icon: category.icon,
                        tint: category.color
                    ) {
                        categoryView(for: category)
                    }
                }
            }
            .navigationTitle("Health Records")
            .toolbar {
                ToolbarItem {
                    CategoryAddMenu { category in
                        selectedCategory = category
                        isAddingRecord = true
                    }
                }
            }
            .sheet(isPresented: $isAddingRecord) {
                addRecordSheet()
            }
        }
    }

    @ViewBuilder
    private func categoryView(for category: HealthRecordCategory) -> some View {
        switch category {
        case .dietary:
            CategoryView<DietaryCalorie>(category)
        case .active:
            CategoryView<ActiveEnergy>(category)
        case .resting:
            CategoryView<RestingEnergy>(category)
        case .weight:
            CategoryView<Weight>(category)
        }
    }

    @ViewBuilder
    private func addRecordSheet() -> some View {
        let newRecord = selectedCategory.createRecord()
        RecordSheetView(
            record: newRecord,
            isPresented: $isAddingRecord
        )
    }
}

// MARK: Category View
// ============================================================================

/// A view that displays records of a specific type with source filtering.
private struct CategoryView<T: HealthRecord>: View {
    @Environment(\.modelContext) private var context: ModelContext
    @DataQuery var records: [T]

    @State private var selectedSources: [DataSource] = []
    @State private var newRecord: T
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
        _newRecord = category.state()
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
        .sheet(isPresented: $isAddingRecord) {
            sheet()
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

    private func sheet() -> some View {
        RecordSheetView(
            record: newRecord,
            isPresented: $isAddingRecord,
            onSave: {
                newRecord = category.state().wrappedValue  // Reset
            }
        )
    }

    @ViewBuilder
    private func loadMoreButton() -> some View {
        if $records.hasMoreData && !$records.isLoading {
            Button("Load More") {
                Task {
                    await $records.load()
                }
            }
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
        }

        if $records.isLoading {
            HStack {
                Spacer()
                ProgressView()
                    .scaleEffect(0.8)
                Spacer()
            }
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder
    private func swipeActions(for record: T) -> some View {
        if record.source == .local {
            Button(role: .destructive) {
                context.delete(record)
                save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            AppLogger.new(for: T.self)
                .error("Failed to save model: \(error)")
        }
    }
}

// MARK: Record Sheet View
// ============================================================================

/// A reusable sheet view for adding/editing health records.
private struct RecordSheetView: View {
    @Environment(\.modelContext) private var context: ModelContext
    let record: any HealthRecord
    @Binding var isPresented: Bool
    var onSave: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            HealthRecordCategory.recordSheet(record)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isPresented = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            isPresented = false
                            context.insert(record)
                            save()
                            onSave?()
                        }
                    }
                }
        }
    }

    private func save() {
        do {
            try context.save()
        } catch {
            AppLogger.new(for: type(of: record))
                .error("Failed to save model: \(error)")
        }
    }
}

// MARK: DataSource Filter Menu
// ============================================================================

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
                                selected.append(source)
                            } else {
                                selected.removeAll { $0 == source }
                            }
                        }
                    )
                ) {
                    Text(source.localized)
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
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
        }
    }
}

// MARK: Category Add Menu
// ============================================================================

/// A specialized add menu for HealthRecordCategory selection.
private struct CategoryAddMenu: View {
    let action: (HealthRecordCategory) -> Void

    init(_ action: @escaping (HealthRecordCategory) -> Void) {
        self.action = action
    }

    var body: some View {
        Menu {
            ForEach(HealthRecordCategory.allCases, id: \.self) { category in
                Button(action: { action(category) }) {
                    Label {
                        Text(category.localized)
                    } icon: {
                        category.icon
                    }
                }
            }
        } label: {
            Label("Add", systemImage: "plus")
        }
    }
}
