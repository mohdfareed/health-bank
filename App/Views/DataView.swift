import SwiftData
import SwiftUI

struct HealthDataView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @RecordsQuery(from: .distantPast, to: .distantFuture, pageSize: 10)
    private var records

    @State private var selectedFilters: [HealthRecordCategory] = []
    @State private var newRecord: any HealthRecord = DietaryCalorie(0)
    @State private var isAddingRecord = false

    private var filteredRecords: [any HealthRecord] {
        records.filter { record in
            if selectedFilters.isEmpty {
                return true  // No filter applied, show all records
            }
            return selectedFilters.contains(where: {
                type(of: $0.record) == type(of: record)
            })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredRecords, id: \.id) { record in
                    HealthRecordCategory.recordRow(record)
                        .swipeActions {
                            if record.source == .local {
                                Button(role: .destructive) {
                                    context.delete(record)
                                    save()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                }

                // Load more button
                if $records.hasMoreData && !$records.isLoading {
                    loadButton()
                }

                // Loading indicator for pagination
                if $records.isLoading {
                    loadingIndicator()
                }
            }
            .navigationTitle("Health Records")
            .animation(.default, value: selectedFilters)
            .animation(.default, value: $records.isLoading)
            .animation(.default, value: $records.hasMoreData)

            .refreshable {
                await $records.reload()
            }
            .task {
                await $records.reload()
            }
            .toolbar {
                toolbar()
            }
            .sheet(isPresented: $isAddingRecord) {
                sheet()
            }
        }
    }

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            HealthRecordCategory.filterMenu($selectedFilters)
        }
        ToolbarItem {
            HealthRecordCategory.addMenu {
                newRecord = $0
                isAddingRecord = true
            }
        }
    }

    private func sheet() -> some View {
        NavigationStack {
            HealthRecordCategory.recordSheet(newRecord)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            isAddingRecord = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            isAddingRecord = false
                            context.insert(newRecord)
                            save()
                        }
                    }
                }
        }
    }

    private func loadButton() -> some View {
        Button("Load More") {
            Task {
                await $records.load()
            }
        }
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
    }

    private func loadingIndicator() -> some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(0.8)
            Spacer()
        }
        .listRowSeparator(.hidden)
    }

    private func save() {
        do {
            try context.save()
        } catch {
            AppLogger.new(for: HealthDataView.self)
                .error("Failed to save model: \(error)")
        }
    }
}
