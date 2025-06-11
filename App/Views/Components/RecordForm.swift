import SwiftData
import SwiftUI

enum RecordFormType {
    case view, create, edit
}

struct RecordForm<R: HealthData, Content: View>: View {
    @Environment(\.healthKit) private var healthKit
    @Environment(\.dismiss) private var dismiss

    @State private var showConfirmation = false

    let title: String.LocalizationValue
    let formType: RecordFormType

    let saveFunc: (R) -> Void
    let deleteFunc: (R) -> Void

    @Binding var record: R
    @ViewBuilder let content: (Binding<R>) -> Content

    var body: some View {
        Form {
            content($record)

            Section {
                DatePicker(
                    selection: $record.date,
                    displayedComponents: [.date, .hourAndMinute]
                ) {
                    Label {
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.gray)
                    }
                }
                .disabled(formType == .view)
            }

            if formType != .create {
                LabeledContent {
                    Text(record.source.localized)
                        .foregroundStyle(.tertiary)
                } label: {
                    Label {
                        Text("Source")
                    } icon: {
                        record.source.icon
                            .foregroundStyle(Color.accent)
                    }
                }
            }

            if formType == .edit {
                Section {
                    Button(role: .destructive) {
                        showConfirmation = true
                    } label: {
                        Text("Delete Record")
                    }
                }

            }
        }
        .navigationTitle(String(localized: title))
        .scrollDismissesKeyboard(.immediately)

        .toolbar {
            if formType == .view {  // HealthKit samples
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        dismiss()
                    }
                }
            } else if formType == .edit {  // App samples
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") {
                        saveFunc(record)
                        dismiss()
                    }
                    .tint(.accent)
                }
            } else {  // New (app) samples
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xcross") {
                        dismiss()
                    }
                    .tint(.red)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", systemImage: "plus") {
                        saveFunc(record)
                        dismiss()
                    }
                    .tint(.green)
                }
            }
        }.toolbarTitleDisplayMode(.inline)

        .confirmationDialog(
            "Delete \(String(localized: title)) Record",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteFunc(record)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
