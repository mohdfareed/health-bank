import Combine
import SwiftData
import SwiftUI

struct LogEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: LogEntryVM

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Entry Details")) {
                    DatePicker("Date & Time", selection: $viewModel.entryDate)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    TextField("Calorie Amount", value: $viewModel.calorieAmount, format: .number)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Log Entry")
            #if !os(macOS)
                .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.submitEntry()
                        dismiss()
                    }
                }
            }
        }
    }
}
