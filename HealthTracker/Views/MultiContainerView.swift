import Combine
import SwiftData
import SwiftUI

struct DataRecordsView<Model: DataRecord, Content: View>: View {
    @Environment(\.modelContext) private var localContext
    @Environment(\.previewContext) private var remoteContext

    @Query private var localRecords: [Model]
    @ViewBuilder private let content: ([Model]) -> Content
    private let queryGenerator: () -> Query<Model, [Model]>

    var body: some View {
        RemoteContainer(self.queryGenerator) { remoteRecords in
            self.content(remoteRecords)
                .environment(\.modelContext, self.localContext)
        }.environment(\.modelContext, self.remoteContext)
    }

    init(
        _ descriptor: FetchDescriptor<Model> = .init(),
        animation: Animation = .default,
        @ViewBuilder content: @escaping ([Model]) -> Content
    ) {
        self.queryGenerator = {
            Query<Model, [Model]>(descriptor, animation: animation)
        }
        self.content = content
        self._localRecords = self.queryGenerator()
    }

    private struct RemoteContainer<RemoteContent: View>: View {
        @Query var remoteRecords: [Model]
        @ViewBuilder let content: ([Model]) -> RemoteContent
        var body: some View { self.content(self.remoteRecords) }

        init(
            _ generator: () -> Query<Model, [Model]>,
            @ViewBuilder content: @escaping ([Model]) -> RemoteContent
        ) {
            self._remoteRecords = generator()
            self.content = content
        }
    }
}

extension EnvironmentValues {
    @Entry var previewContext: ModelContext = {
        ModelContext(
            try! ModelContainer(
                configurations: ModelConfiguration(
                    isStoredInMemoryOnly: true
                )
            )
        )
    }()
}

extension View {
    func remoteContext(_ context: ModelContext) -> some View {
        self.environment(\.previewContext, context)
    }
}
