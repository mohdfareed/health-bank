import Combine
import SwiftData
import SwiftUI

struct LogEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: LogEntryVM

    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Date & Time", selection: $viewModel.entryDate)
                        .datePickerStyle(GraphicalDatePickerStyle())
                    TextField(
                        "Calories",
                        value: $viewModel.calorieAmount,
                        format: .number
                    )
                }
                .onChange(of: viewModel.calorieAmount) {
                    self.viewModel.onDataChange()
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
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}
