import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Query private var entries: [CalorieEntry]

    var body: some View {
        NavigationSplitView {
            List {
                // ForEach(items) { item in
                //     NavigationLink {
                //         Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                //     } label: {
                //         Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                //     }
                // }
                // .onDelete(perform: deleteItems)
            }
            #if os(macOS)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            #endif
            .toolbar {
                #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                #endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem: CalorieEntry = CalorieEntry(calories: 0, date: Date(), source: .manual)
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(entries[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CalorieEntry.self, inMemory: true)
}
