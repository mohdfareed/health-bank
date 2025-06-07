import SwiftData
import SwiftUI

// TODO: Remove icons from record row for category views.

/// A view that displays records of a specific type with source filtering.
struct CategoryView<T: HealthDate>: View {
    @Environment(\.modelContext) private var context: ModelContext
    @DataQuery var records: [T]
    @State private var isAddingRecord = false

    private let category: HealthRecordCategory
    private let query: any HealthQuery<T>

    init(_ category: HealthRecordCategory) {
        self.category = category
        self.query = category.query()
        _records = DataQuery(
            query, from: .distantPast, to: .distantFuture
        )
    }

    var body: some View {
        List {
            ForEach(records) { record in
                HealthRecordCategory.recordRow(record)
                    .swipeActions { swipeActions(for: record) }
            }
            loadMoreButton()
        }
        .navigationTitle(category.localized)
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
        if record.isInternal {
            Button(role: .destructive) {
                // TODO: Implement delete action
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
