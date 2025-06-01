import SwiftData
import SwiftUI

struct RecordForm<R: HealthRecord & PersistentModel, Content: View>: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmation = false

    let title: String.LocalizationValue
    let record: R
    @State private var date: Date
    @ViewBuilder let content: () -> Content

    init(
        _ title: String.LocalizationValue,
        record: R, isValid: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._date = State(initialValue: record.date)
        self.title = title
        self.record = record
        self.content = content
    }

    var body: some View {
        NavigationStack {
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
                    .onChange(of: date) {
                        saveRecord()
                    }
                }

                if record.source == .local {
                    Section {
                        Button(role: .destructive) {
                            showConfirmation = true
                        } label: {
                            Text("Delete Record")
                        }
                    }
                } else {
                    Section {
                        LabeledContent {
                            Text(record.source.localized)
                        } label: {
                            Label {
                            } icon: {
                                record.source.icon?
                                    .foregroundStyle(record.source.color)
                            }
                        }
                    }
                }
            }
            .disabled(record.source != .local)
            .navigationTitle(String(localized: title))
            .confirmationDialog(
                "Delete \(String(localized: title)) Record",
                isPresented: $showConfirmation,
                titleVisibility: .visible
            ) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) { deleteRecord() }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private func saveRecord() {
        record.date = date
        try? context.save()
        dismiss()
    }

    private func deleteRecord() {
        context.delete(record)
        try? context.save()
        dismiss()
    }
}
