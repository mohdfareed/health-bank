import SwiftData
import SwiftUI

struct RecordForm<R: HealthData, Content: View>: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmation = false

    let title: String.LocalizationValue
    let record: R
    let isEditing: Bool
    @State private var date: Date
    @ViewBuilder let content: () -> Content

    init(
        _ title: String.LocalizationValue, record: R, isEditing: Bool,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._date = State(initialValue: record.date)
        self.title = title
        self.record = record
        self.content = content
        self.isEditing = isEditing
    }

    var body: some View {
        Form {
            content()

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
            }
            .disabled(record.source != .app)

            if isEditing && record.source == .app {
                Section {
                    Button(role: .destructive) {
                        showConfirmation = true
                    } label: {
                        Text("Delete Record")
                    }
                }

            }

            Section {
                LabeledContent {
                    Text(record.source.localized)
                } label: {
                    Label {
                        Text("Source")
                    } icon: {
                        record.source.icon
                            .foregroundStyle(record.source.color)
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
        // TODO: Implement saving logic
        // record.date = date
        // if !isEditing {
        //     context.insert(record)
        // }
        // try? context.save()
    }

    private func deleteRecord() {
        // TODO: Implement deletion logic
        // context.delete(record)
        // try? context.save()
    }
}

// MARK: Initializers
// ============================================================================

extension RecordForm {
    init(  // For create mode (when record is new)
        _ title: String.LocalizationValue, creating record: R,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title, record: record, isEditing: false,
            content: content
        )
    }

    init(  // For edit mode (when record exists)
        _ title: String.LocalizationValue, editing record: R,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(
            title, record: record, isEditing: true,
            content: content
        )
    }
}
