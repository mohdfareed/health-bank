import Combine
import SwiftData
import SwiftUI

struct CalorieEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State var entry: CalorieEntry
    @State private var calories: Int?
    @State var canSave: Bool = false

    private let caloriesService: CaloriesService
    private let isEditing: Bool

    private var title: Text {
        !self.isEditing ? Text("Log Calories") : Text("Edit Entry")
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date & Time", selection: $entry.date)
                    .datePickerStyle(GraphicalDatePickerStyle())

                HStack {
                    Text("Calories")
                    Spacer()
                    TextField(
                        "Amount", value: $calories,
                        format: .number
                    )
                    .multilineTextAlignment(.trailing)
                    .onChange(of: calories) { _, new in
                        self.entry.calories = new ?? 0
                        self.canSave = new != 0
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
