import SwiftData
import SwiftUI

struct HealthDataView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @RecordsQuery private var records

    @State private var selectedTypes: [HealthRecordCategory] = []
    @State private var selectedNewType: HealthRecordCategory = .dietary
    @State private var isPresentingForm = false

    private var filteredRecords: [any HealthRecord & PersistentModel] {
        records.filter { record in
            if selectedTypes.isEmpty {
                return true  // No filter applied, show all records
            }
            return selectedTypes.contains(where: {
                type(of: $0.record) == type(of: record)
            })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredRecords, id: \.id) { record in
                    HealthRecordCategory.recordRow(record)
                }
            }
            .navigationTitle("Health Records")
            .animation(.default, value: selectedTypes)

            .refreshable {
                await $records.refresh()
            }

            .toolbar {
                ToolbarItem(placement: .navigation) {
                    HealthRecordCategory.filterMenu($selectedTypes)
                }
                ToolbarItem {
                    HealthRecordCategory.addMenu {
                        selectedNewType = $0
                        isPresentingForm = true
                    }
                }
            }
        }

        .sheet(isPresented: $isPresentingForm) {
            let newRecord = selectedNewType.record
            NavigationStack {
                HealthRecordCategory.recordSheet(newRecord)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPresentingForm = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                isPresentingForm = false
                                context.insert(newRecord)
                                save()
                            }
                        }
                    }
            }
        }
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
