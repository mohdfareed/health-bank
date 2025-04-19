import HealthKit
import SwiftData
import SwiftUI

@Model final class PreviewDataModel: DataRecord {
    var id: UUID = UUID()
    var source = DataSource()
    var value: Int = Int.random(in: 0...10)
    init() {}
}

extension PreviewDataModel {
    typealias Query = PreviewQuery
    struct PreviewQuery: RemoteQuery {
        typealias Model = PreviewDataModel
        var min: Int = 0
        var max: Int = 10
        var sort: SortDescriptor<Model> = .init(\.value, order: .reverse)
    }
}

extension PreviewDataModel.PreviewQuery: CoreQuery {
    var descriptor: FetchDescriptor<PreviewDataModel> {
        let (min, max) = (self.min, self.max)
        return FetchDescriptor<PreviewDataModel>(
            predicate: #Predicate {
                $0.value >= min && $0.value <= max
            },
            sortBy: [self.sort]
        )
    }
}

extension PreviewDataModel.PreviewQuery: SimulationQuery {
    var predicate: Predicate<PreviewDataModel> { self.descriptor.predicate! }
}

// MARK: Preview
// ============================================================================

struct PreviewDataEditor<Query: RemoteQuery, RowContent: View>: View
where Query.Model: PersistentModel {
    @Environment(\.modelContext) private var context
    @Environment(\.remoteContext) private var remoteContext
    @DataQuery var data: [Query.Model]

    private let factory: (() -> Query.Model)?
    private let editor: ((Query.Model) -> Void)?
    private let rowContent: (Query.Model) -> RowContent

    init(
        _ query: Query,
        factory: (() -> Query.Model)? = nil, editor: ((Query.Model) -> Void)? = nil,
        @ViewBuilder _ rowContent: @escaping (Query.Model) -> RowContent
    ) where Query: CoreQuery {
        self.factory = factory
        self.editor = editor
        self.rowContent = rowContent
        self._data = .init(query, inMemory: .init(sortOrder: query.descriptor.sortBy))
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
                ToolbarItemGroup(placement: .automatic) {
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
                    // let remote = factory(source: .simulation)
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
                    let added = self.context.insertedModelsArray
                        .compactMap { $0 as? any DataRecord }
                    let deleted = self.context.deletedModelsArray
                        .compactMap { $0 as? any DataRecord }
                    let modified = self.context.changedModelsArray
                        .compactMap { $0 as? any DataRecord }

                    print("Syncing: \(added + deleted + modified)")
                    try self.remoteContext.sync(
                        added: added, deleted: deleted, modified: modified
                    )
                    try self.context.save()
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
            UserDefaults.standard.removePersistentDomain(forName: appID)
        }

        var body: some View {
            PreviewDataEditor(
                PreviewDataModel.PreviewQuery(),
                factory: { PreviewDataModel() },
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
            for: PreviewDataModel.self, inMemory: true
        )
        .remoteContext(
            .init(stores: [SimulatedStore(for: [PreviewDataModel()])])
        )
        .preferredColorScheme(.dark)
}
