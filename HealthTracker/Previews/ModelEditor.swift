import SwiftData
import SwiftUI

struct PreviewModelEditor<Model: PersistentModel, RowContent: View>: View {
    @Environment(\.modelContext) var context
    @State private var model: Model

    private let editor: ((Model) -> Void)?
    private let rowContent: (Model) -> RowContent

    init(
        model: Model, editor: ((Model) -> Void)? = nil,
        @ViewBuilder _ rowContent: @escaping (Model) -> RowContent
    ) {
        self.model = model
        self.editor = editor
        self.rowContent = rowContent
    }

    var body: some View {
        HStack {
            Text("\(model.id.hashValue)").foregroundColor(.pink)
            Spacer()
            if self.context.insertedModelsArray.contains(where: { $0.id == model.id }) {
                Image(systemName: "plus").foregroundStyle(.green)
            } else if self.context.changedModelsArray.contains(where: { $0.id == model.id }) {
                Image(systemName: "pencil").foregroundStyle(.purple)
            } else if self.context.deletedModelsArray.contains(where: { $0.id == model.id }) {
                Image(systemName: "trash").foregroundStyle(.red)
            } else {
                Image(systemName: "checkmark").foregroundStyle(.blue)
            }
        }
        rowContent(model)
        HStack {
            saveButton(model).buttonStyle(.borderless)
            Spacer()
            editButton(model).buttonStyle(.borderless)
            Spacer()
            deleteButton(model).buttonStyle(.borderless)
        }
    }

    private func editButton(_ item: Model) -> some View {
        AnyView(
            Button(action: {
                self.editor?(item)
            }) {
                if item.hasChanges {
                    Image(systemName: "pencil").tint(.purple)
                } else {
                    Image(systemName: "pencil")
                }
            }
        )
    }

    private func deleteButton(_ item: Model) -> some View {
        AnyView(
            Button(action: {
                self.context.delete(item)
            }) {
                if item.isDeleted {
                    Image(systemName: "trash.slash").tint(.red)
                } else {
                    Image(systemName: "trash")
                }
            }
        )
    }

    private func saveButton(_ item: Model) -> some View {
        AnyView(
            Button(action: {
                let model: Model? = context.registeredModel(
                    for: self.model.persistentModelID
                )

                if model == nil {
                    self.context.insert(self.model)
                }

                do {
                    try self.context.save()
                } catch {
                    print("Failed to save \(Model.self): \(error)")
                }
            }) {
                let model: Model? = context.registeredModel(
                    for: self.model.persistentModelID
                )
                if model != nil {
                    Image(systemName: "square.and.arrow.down").tint(.green)
                } else {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        )
    }
}

@MainActor func row(_ name: String, value: String) -> some View {
    HStack {
        Text(name).foregroundStyle(.primary)
        Spacer()
        Text(value).foregroundColor(.secondary)
    }
}

// MARK: Preview

#if DEBUG
    @Model final class PreviewModel {
        @Attribute(.unique) var id: UUID = UUID()
        var value: Int = 0
        init() {}
    }

    struct PreviewModelEditorView: View {
        @Query var models: [PreviewModel]
        var model: PreviewModel? { models.first }

        var body: some View {
            List {
                PreviewModelEditor(
                    model: model ?? PreviewModel(),
                    editor: { $0.value = Int.random(in: 0..<100) }
                ) { row("Value", value: "\($0.value)") }
            }
        }
    }
#endif

#Preview {
    PreviewModelEditorView()
        .modelContainer(for: PreviewModel.self, inMemory: true)
        .preferredColorScheme(.dark)
}
