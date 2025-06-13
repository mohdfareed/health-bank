import SwiftData
import SwiftUI

enum RecordFormType {
    case view, create, edit
}

// TODO: Show loading indicator when saving/deleting records
// Indicator is shown by replacing button (or its icon) with a progress view

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
        }
        .navigationTitle(String(localized: title))
        .scrollDismissesKeyboard(.immediately)

        .toolbar {
            if formType == .view {  // HealthKit samples
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26, *) {
                        Button(role: .close) {
                            dismiss()
                        } label: {
                            Label("Done", systemImage: "checkmark")
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Label("Done", systemImage: "checkmark")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            } else if formType == .edit {  // App samples
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .destructive) {
                        showConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26, *) {
                        Button(role: .confirm) {
                            saveFunc(record)
                            dismiss()
                        } label: {
                            Label("Save", systemImage: "checkmark")
                        }
                    } else {
                        Button {
                            saveFunc(record)
                            dismiss()
                        } label: {
                            Label("Save", systemImage: "checkmark")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            } else {  // New (app) samples
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if #available(iOS 26, *) {
                        Button(role: .confirm) {
                            saveFunc(record)
                            dismiss()
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    } else {
                        Button {
                            saveFunc(record)
                            dismiss()
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
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
                deleteFunc(record)
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
