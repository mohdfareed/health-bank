import SwiftData
import SwiftUI

// MARK: Editor

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
        VStack {
            HStack {
                Spacer()
                Text("\(String(describing: model.persistentModelID.hashValue))")
                    .multilineTextAlignment(.center)
                    .font(.footnote).fontDesign(.monospaced).bold()
                Spacer()
            }

            Divider()
            rowContent(model)
            Divider()

            HStack {
                Spacer()
                saveButton(model).buttonStyle(.borderless)
                Spacer()
                editButton(model).buttonStyle(.borderless)
                Spacer()
                deleteButton(model).buttonStyle(.borderless)
                Spacer()
            }
        }
    }
}

// MARK: Buttons & Status

extension PreviewModelEditor {
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
                self.context.insert(self.model)
            }) {
                let registeredModel: Model? = context.registeredModel(
                    for: self.model.persistentModelID
                )
                let isRegistered = registeredModel != nil
                let isPersisted = !self.context.insertedModelsArray.contains(
                    where: {
                        $0.persistentModelID == model.persistentModelID
                    }
                )  // not yet to be persisted

                if isRegistered && isPersisted {  // in-sync
                    Image(systemName: "square.and.arrow.down").tint(.green)
                } else if isRegistered && !isPersisted {
                    Image(systemName: "square.and.arrow.down").tint(.red)
                } else if !isRegistered && isPersisted {
                    Image(systemName: "plus.circle.fill").tint(.green)
                } else {  // !isRegistered && !isPersisted
                    Image(systemName: "plus.circle.fill").tint(.red)
                }
            }
        )
    }
}

// MARK: Card Design

extension PreviewModelEditor {
    static func card(
        model: Model, editor: ((Model) -> Void)? = nil,
        @ViewBuilder _ rowContent: @escaping (Model) -> RowContent
    ) -> some View {
        Group {
            PreviewModelEditor(model: model, editor: editor) {
                rowContent($0)
            }
        }
        .padding()
        .background(.background.secondary)
        .cornerRadius(12)
        .padding()
    }
}

@MainActor func cardRow(_ name: String, value: String) -> some View {
    HStack {
        Text(name).foregroundStyle(.primary)
        Spacer()
        Text(value).foregroundColor(.secondary)
    }
}

// MARK: Preview

#if DEBUG
    @Model final class PreviewModel {
        var value: Int = 0
        init() {}
    }

    struct PreviewModelEditorView: View {
        @Environment(\.modelContext) var context
        @Query(animation: .default) var models: [PreviewModel]

        var model: PreviewModel? { models.first }
        var body: some View {
            switch models.count {
            case 0:
                Text("No models found.").foregroundStyle(.red).padding()
                Button("Create") {
                    self.context.insert(PreviewModel())
                }.buttonStyle(.borderedProminent)
            default:
                withAnimation{
                    PreviewModelEditor.card(model: model!) {
                        cardRow("Value", value: "\($0.value)")
                    }
                }
                Button("Save") {
                    try! self.context.save()
                }
            }
        }
    }
#endif

#Preview {
    PreviewModelEditorView()
        .modelContainer(
            for: PreviewModel.self, inMemory: true,
            isAutosaveEnabled: false
        )
        .preferredColorScheme(.dark)
        .resetSettings()
}
