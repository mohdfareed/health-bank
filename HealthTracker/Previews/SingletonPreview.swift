import SwiftData
import SwiftUI

#if DEBUG
    struct PreviewSingleton: View {
        @Environment(\.modelContext) var context: ModelContext
        @Query.Singleton var model: PreviewModel?
        @Query.Settings(\PreviewSettingsModel.singleton)
        var singletonID: PersistentIdentifier?

        init() {
            self._model = .init(self.singletonID)
        }

        var body: some View {
            VStack {
                HStack {
                    Text("Singleton").font(.largeTitle)
                    Spacer()
                    Button(action: {
                        if true {

                        }
                        createSingleton()
                    }) {
                        Text("Create Singleton")
                    }
                }.padding()

                if let id = self.singletonID {
                    Text("\(id)").tint(.pink)
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .fontDesign(.monospaced)
                } else {
                    Text("No singleton ID stored.").tint(.pink)
                }

                // REVIEW: should user be able to check if a singleton exists?
                if let model = model {
                    PreviewModelEditor.card(
                        model: model,
                        editor: { $0.value = Int.random(in: 0..<100) }
                    ) { cardRow("Singleton", value: "\($0.value)") }
                } else {
                    Text("No singleton instance found.")
                        .foregroundStyle(.red).padding()
                }
            }
            .padding()

            TableEditor(
                factory: { PreviewModel() },
                editor: { $0.value = Int.random(in: 0..<100) }
            ) { item in
                cardRow(
                    item.id == model?.persistentModelID
                        ? "Singleton" : "\(type(of: item).self)",
                    value: "\(item.value)"
                )
            }
            .cornerRadius(25)
        }

        private func createSingleton() {
            let model = PreviewModel()
            self.context.insert(model)
            try? self.context.save()

            self.singletonID = model.id
            // TODO: Refresh singleton query
        }
    }
#endif

#Preview {
    PreviewSingleton()
        .modelContainer(
            for: PreviewModel.self,
            inMemory: true,
            isAutosaveEnabled: false
        )
        .preferredColorScheme(.dark)
}
