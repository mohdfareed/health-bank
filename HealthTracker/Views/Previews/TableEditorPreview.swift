import SwiftData
import SwiftUI

struct PreviewTableEditor<Model: PersistentModel, RowContent: View>: View {
    @Environment(\.modelContext) var context: ModelContext
    @Query(animation: .default) private var models: [Model]

    private let factory: (() -> Model)?
    private let editor: ((Model) -> Void)?
    private let rowContent: (Model) -> RowContent

    private var allModels: [Model] {
        let deleted = self.context.deletedModelsArray.filter { $0 is Model }
        return (self.models + (deleted as? [Model] ?? [])).sorted(by: {
            $0.id < $1.id
        })
    }

    init(
        factory: (() -> Model)? = nil, editor: ((Model) -> Void)? = nil,
        @ViewBuilder _ rowContent: @escaping (Model) -> RowContent
    ) {
        self.factory = factory
        self.editor = editor
        self.rowContent = rowContent
    }

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(self.allModels, id: \.id) {
                    PreviewModelEditor.card(model: $0, editor: editor) {
                        self.rowContent($0)

                    }
                }
            }
            .navigationTitle("Editor")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    addButton()
                }
                ToolbarItemGroup(placement: .cancellationAction) {
                    saveButton()
                }
                ToolbarItemGroup(placement: .principal) {
                    Text("Models: \(self.allModels.count)")
                        .font(.footnote).fontDesign(.monospaced)
                        .foregroundStyle(.secondary)
                }
            }
            .animation(.default, value: self.allModels)
        }
    }

    private func addButton() -> some View {
        var view = AnyView(EmptyView())
        if let factory = self.factory {
            view = AnyView(
                Button(action: {
                    self.context.insert(factory())
                }) { Image(systemName: "plus") }
            )
        }
        return view
    }

    private func saveButton() -> some View {
        AnyView(
            Button(action: {
                do {
                    try self.context.save()
                } catch {
                    print("Failed to save: \(error)")
                }
            }) { Image(systemName: "square.and.arrow.down") }
        )
    }
}

// MARK: Preview

#if DEBUG
    struct PreviewModelTableView: View {
        @Query var models: [PreviewModel]

        init() {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }

        var body: some View {
            PreviewTableEditor(
                factory: { PreviewModel() },
                editor: { $0.value = Int.random(in: 0..<100) }
            ) { cardRow("Value", value: "\($0.value)") }
        }
    }
#endif

#Preview {
    PreviewModelTableView()
        .modelContainer(
            for: PreviewModel.self, inMemory: true,
            isAutosaveEnabled: false
        )
        .preferredColorScheme(.dark)
}
