import Combine
import SwiftData
import SwiftUI

@Observable
class CalorieEditorVM<T: DataEntry>: ConsumedCalories {
    var model: any PersistentModel & DataEntry {
        self.calories >= 0
            ? ConsumedCalories(
                UInt(self.calories), on: self.date,
                macros: CalorieMacros(
                    protein: UInt(self.calories),
                    fat: UInt(self.calories),
                    carbs: UInt(self.calories)
                )
            )
            : BurnedCalories(
                UInt(-self.calories), on: self.date
            )
    }

    init(_ entry: T? = nil) {
        self.date = entry?.date ?? Date.now
        self.calories = entry?.calories ?? 0
        self.source = entry?.source ?? .manual
        self.description = entry?.description ?? String(describing: self)
    }
}

struct CalorieEditorView<T: CalorieEntry>: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State var entry: CalorieEditorVM
    @State var canSave: Bool = false

    private let dataService: DataEntryService
    private let isEditing: Bool

    private var title: Text {
        !self.isEditing ? Text("Log Calories") : Text("Edit Entry")
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date & Time", selection: $entry.date)
                    .datePickerStyle(GraphicalDatePickerStyle())

                EntryItem(title: "Calories", entry: $entry.calories, unit: "cal")
                EntryItem(title: "Protein", entry: $entry.calories, unit: "g")
                EntryItem(title: "Carbohydrates", entry: $entry.calories, unit: "g")
                EntryItem(title: "Fat", entry: $entry.calories, unit: "g")
            }

            .toolbar {
                ToolbarItem(placement: .principal) {
                    self.title
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation {
                            self.dataService.create(entry.model)
                            dismiss()
                        }
                    }
                    .disabled(!self.canSave)
                }
            }
        }
    }

    init(dataService: DataEntryService, entry: CalorieEntry? = nil) {
        self.dataService = dataService
        self.entry = CalorieEditorVM(entry)
        self.isEditing = entry != nil
    }
}

struct EntryItem: View {
    var title: String
    @Binding var entry: Int
    var unit: String?
    var placeholder: String = "Amount"

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            TextField(placeholder, value: $entry, format: .number)
                .multilineTextAlignment(.trailing)
                .font(.subheadline)
            if let unit = self.unit {
                Text(unit)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
