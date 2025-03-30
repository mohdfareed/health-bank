import SwiftData
import SwiftUI

struct TableEditor<Model: PersistentModel, RowContent: View>: View {
    @Environment(\.modelContext) var context: ModelContext
    @Query(animation: .default) private var models: [Model]

    private let factory: () -> Model
    private let modifier: ((Model) -> Void)?
    private let rowContent: (Model) -> RowContent

    private var allModels: [Model] {
        let deleted = self.context.deletedModelsArray.filter { $0 is Model }
        return self.models + (deleted as! [Model])
    }

    init(
        factory: @escaping () -> Model,
        modifier: ((Model) -> Void)? = nil,
        @ViewBuilder _ rowContent: @escaping (Model) -> RowContent
    ) {
        self.factory = factory
        self.modifier = modifier
        self.rowContent = rowContent
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(self.allModels, id: \.id) {
                    PreviewModelEditor(model: $0, editor: modifier) {
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
            }
        }
    }

    private func addButton() -> some View {
        AnyView(
            Button(action: {
                self.context.insert(self.factory())
            }) { Image(systemName: "plus") }
        )
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

        var body: some View {
            TableEditor(
                factory: { PreviewModel() },
                modifier: { $0.value = Int.random(in: 0..<100) }
            ) { row("Value", value: "\($0.value)") }
        }
    }
#endif

#Preview {
    PreviewModelTableView()
        .modelContainer(for: PreviewModel.self, inMemory: true)
        .preferredColorScheme(.dark)
}
