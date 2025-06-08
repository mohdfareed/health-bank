import SwiftData
import SwiftUI

struct RecordForm<R: CopyableHealthData, Content: View>: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmation = false

    let title: String.LocalizationValue
    let originalRecord: R
    let isEditing: Bool
    @State private var editableRecord: R
    @State private var date: Date
    @ViewBuilder let content: (R) -> Content

    init(
        _ title: String.LocalizationValue, record: R, isEditing: Bool,
        @ViewBuilder content: @escaping (R) -> Content
    ) {
        self.title = title
        self.originalRecord = record
        self.isEditing = isEditing
        self.content = content

        // Initialize state with copies
        self._editableRecord = State(initialValue: record.copy())
        self._date = State(initialValue: record.date)
    }

    var body: some View {
        Form {
            content(editableRecord)

            Section {
                DatePicker(
                    selection: $date,
                    displayedComponents: [.date, .hourAndMinute]
                ) {
                    Label {
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundStyle(.gray)
                    }
                }
                .disabled(editableRecord.source != .app)
            }

            LabeledContent {
                Text(editableRecord.source.localized)
                    .foregroundStyle(.tertiary)
            } label: {
                Label {
                    Text("Source")
                        .foregroundStyle(.secondary)
                } icon: {
                    editableRecord.source.icon
                        .foregroundStyle(Color.accent)
                }
            }

            if isEditing && editableRecord.source == .app {
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
            if isEditing {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveRecord()
                        dismiss()
                    }
                }

            } else {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveRecord()
                        dismiss()
                    }
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
                deleteRecord()
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func saveRecord() {
        // Apply changes from editable record to original
        editableRecord.date = date

        if isEditing {
            // Copy values from editable record to original
            originalRecord.copyValues(from: editableRecord)
        } else {
            // For new records, the editableRecord is the one to save
            // TODO: Implement saving logic (requires query object)
            // context.insert(editableRecord)
        }

        // TODO: Implement saving logic (requires query object)
        // try? context.save()
    }

    private func deleteRecord() {
        // TODO: Implement deletion logic
        // context.delete(originalRecord)
        // try? context.save()
    }
}

// MARK: Initializers
// ============================================================================

extension RecordForm {
    init(  // For create mode (when record is new)
        _ title: String.LocalizationValue, creating record: R,
        @ViewBuilder content: @escaping (R) -> Content
    ) {
        self.init(
            title, record: record, isEditing: false,
            content: content
        )
    }

    init(  // For edit mode (when record exists)
        _ title: String.LocalizationValue, editing record: R,
        @ViewBuilder content: @escaping (R) -> Content
    ) {
        self.init(
            title, record: record, isEditing: true,
            content: content
        )
    }
}
