import Combine
import SwiftData
import SwiftUI

struct CalorieEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State var entry: CalorieEntry
    @State var newDate: Bool = false
    @State var newCalories: Bool = false
    @State var canSave: Bool = false

    private let caloriesService: CaloriesService
    private let isEditing: Bool

    private var title: Text {
        !self.isEditing ? Text("Log Calories") : Text("Edit Entry")
    }
    private var isValid: Bool {
        self.newDate || self.newCalories
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date & Time", selection: $entry.date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .onChange(of: entry.date) { _, _ in
                        self.newDate = true
                        self.canSave = self.isValid
                    }

                HStack {
                    Text("Calories")
                    Spacer()
                    TextField("Amount", value: $entry.calories, format: .number)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: entry.calories) { old, new in
                            self.newCalories = new != 0
                            self.canSave = self.isValid
                        }
                }
            }
            .navigationTitle("Log Calories")

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
                            self.caloriesService.create(self.entry)
                            dismiss()
                        }
                    }
                    .disabled(!self.canSave)
                }
            }
        }
    }

    init(caloriesService: CaloriesService, entry: CalorieEntry? = nil) {
        self.caloriesService = caloriesService
        self.entry = entry ?? CalorieEntry(0, on: Date.now)
        self.isEditing = entry != nil
    }
}
