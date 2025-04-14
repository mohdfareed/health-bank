import HealthKit
import SwiftData
import SwiftUI

@Model final class TestModel: DataRecord {
    var id: UUID = UUID()
    var source = DataSource()
    var value: Int = Int.random(in: 0...10)
    init() {}
}

extension TestModel: RemoteRecord {
    typealias Query = TestQuery

    struct TestQuery: RemoteQuery {
        typealias Model = TestModel
        var min: Int = 0
        var max: Int = 10
        var sort: SortDescriptor<TestModel> = .init(\.value, order: .reverse)
    }
}

extension TestModel.TestQuery: CoreQuery {
    var descriptor: FetchDescriptor<TestModel> {
        let (min, max) = (self.min, self.max)
        return FetchDescriptor<TestModel>(
            predicate: #Predicate {
                $0.value >= min && $0.value <= max
            },
            sortBy: [self.sort]
        )
    }
}

extension TestModel: SimulationModel {}
extension TestModel.TestQuery: SimulationQuery {
    var predicate: Predicate<TestModel> { self.descriptor.predicate! }
}

// MARK: Preview
// ============================================================================

struct PreviewDataEditor<Model: RemoteRecord, RowContent: View>: View {
    @Environment(\.modelContext) private var context
    @Environment(\.remoteContext) private var remoteContext
    @Query.Remote var data: [Model]

    private let factory: (() -> Model)?
    private let editor: ((Model) -> Void)?
    private let rowContent: (Model) -> RowContent

    init(
        _ query: Model.Query,
        factory: (() -> Model)? = nil, editor: ((Model) -> Void)? = nil,
        @ViewBuilder _ rowContent: @escaping (Model) -> RowContent
    ) where Model.Query: CoreQuery {
        self.factory = factory
        self.editor = editor
        self.rowContent = rowContent
        self._data = .init(query)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(self.data, id: \.id) {
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
                    Text("Data: \(self.data.count)")
                        .font(.footnote).fontDesign(.monospaced)
                        .foregroundStyle(.secondary)
                }
            }
            .refreshable { self.$data.refresh() }
            .animation(.default, value: self.data)
        }
    }

    private func addButton() -> some View {
        var view = AnyView(EmptyView())
        if let factory = self.factory {
            view = AnyView(
                Button(action: {
                    self.context.insert(factory())
                    let remote = factory()
                    remote.source = .simulation
                    try? self.remoteContext.stores.first?.save(remote)
                }) { Image(systemName: "plus") }
            )
        }
        return view
    }

    private func saveButton() -> some View {
        AnyView(
            Button(action: {
                do {
                    for deleted in self.context.deletedModelsArray {
                        guard let deleted = deleted as? Model else { continue }
                        print("Syncing deleted: \(deleted)")
                        try self.remoteContext.delete(deleted)
                    }
                    for added in self.context.insertedModelsArray {
                        guard let added = added as? Model else { continue }
                        print("Syncing added: \(added)")
                        try self.remoteContext.save(added)
                    }
                    for changed in self.context.changedModelsArray {
                        guard let changed = changed as? Model else { continue }
                        print("Syncing changed: \(changed)")
                        try self.remoteContext.delete(changed)
                        try self.remoteContext.save(changed)
                    }

                    try self.context.save()
                    self.$data.refresh()
                } catch {
                    print("Failed to save: \(error)")
                }
            }) { Image(systemName: "square.and.arrow.down") }
        )
    }
}

#if DEBUG
    struct PreviewDataEditorView: View {
        init() {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }

        var body: some View {
            PreviewDataEditor(
                .init(),
                factory: { TestModel() },
                editor: { $0.value = Int.random(in: 0..<10) }
            ) {
                cardRow("Value", value: "\($0.value)")
                Divider()
                cardRow("Source", value: "\($0.source)")
            }
        }
    }
#endif

#Preview {
    PreviewDataEditorView()
        .modelContainer(
            for: TestModel.self, inMemory: true
        )
        .remoteContext(
            .init(stores: [SimulatedStore(using: [TestModel()])])
        )
        .preferredColorScheme(.dark)
}
