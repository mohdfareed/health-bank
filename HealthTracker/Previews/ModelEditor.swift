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
                if !self.isRegistered {
                    insertButton(model).buttonStyle(.borderless)
                } else {
                    saveButton(model).buttonStyle(.borderless)
                }
                Spacer()
                editButton(model).buttonStyle(.borderless)
                Spacer()
                deleteButton(model).buttonStyle(.borderless)
                Spacer()
            }
        }
        .animation(.default, value: self.isPersisted)
        .animation(.default, value: self.isRegistered)
    }
}

// MARK: Buttons & Status

extension PreviewModelEditor {
    private var isRegistered: Bool {
        let registeredModel: Model? = context.registeredModel(
            for: self.model.persistentModelID
        )
        return registeredModel != nil
    }

    private var isPersisted: Bool {
        let isPersisted = !self.context.insertedModelsArray.contains(
            where: {
                $0.persistentModelID == model.persistentModelID
            }
        )  // not yet to be persisted
        return isPersisted
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

    private func insertButton(_ item: Model) -> some View {
        AnyView(
            Button(action: {
                self.context.insert(self.model)
            }) {
                if self.isRegistered {
                    Image(systemName: "plus.circle.fill").tint(.green)
                } else {
                    Image(systemName: "plus.circle.fill").tint(.red)
                }
            }
        )
    }

    private func saveButton(_ item: Model) -> some View {
        AnyView(
            Button(action: {
                try? self.context.save()
            }) {
                if self.isPersisted {  // in-sync
                    Image(systemName: "square.and.arrow.down").tint(.green)
                } else {  // !isRegistered && !isPersisted
                    Image(systemName: "square.and.arrow.down").tint(.red)
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

        var model: PreviewModel { models.first! }
        var body: some View {
            switch models.count {
            case 0:
                Text("No models found.").foregroundStyle(.red).padding()
                Button("Create") {
                    self.context.insert(PreviewModel())
                }.buttonStyle(.borderedProminent)
            default:
                withAnimation {
                    PreviewModelEditor.card(
                        model: model,
                        editor: {
                            $0.value += 1
                        }
                    ) {
                        cardRow("Value", value: "\($0.value)")
                    }
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
