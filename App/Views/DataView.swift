import SwiftData
import SwiftUI

struct HealthDataView: View {
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
                $0.record == type(of: record)
            })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredRecords, id: \.id) { record in
                    $records.recordRow(record)
                }
            }
            .navigationTitle("Health Records")
            .animation(.default, value: selectedTypes)

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
            NavigationStack {
                selectedNewType.recordSheet
            }
        }

        .refreshable {
            await $records.refresh()
        }
    }
}
