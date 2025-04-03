import SwiftData
import SwiftUI

struct PreviewSingleton: View {
    @Environment(\.modelContext) var context: ModelContext
    @State @Query.Singleton var model: PreviewModel?
    @State var singletonID: PersistentIdentifier?

    init(id: PersistentIdentifier?) {
        self._model = State(wrappedValue: .init(id))
        self.singletonID = id
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Singleton")
                Spacer()

                Button(action: {
                    createSingleton()
                }) {
                    Text(Image(systemName: "plus"))
                        .font(.headline)
                        .foregroundStyle(.blue)
                }
            }.padding()

            if let id = self.singletonID {
                Text("\(id)").tint(.pink)
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .fontDesign(.monospaced)
            } else {
                Text("No singleton ID stored.")
                    .foregroundStyle(.red)
            }

            if let model = model {
                PreviewModelEditor.card(
                    model: model,
                    editor: { $0.value = Int.random(in: 0..<100) }
                ) { cardRow("Singleton Value", value: "\($0.value)") }
            } else {
                Text("No singleton instance found.")
                    .foregroundStyle(.red).padding()
            }
        }
    }

    private func createSingleton() {
        let model = PreviewModel()
        self.context.insert(model)
        try? self.context.save()

        self.singletonID = model.id
        self._model.wrappedValue = .init(self.singletonID)
    }
}

#if DEBUG
    struct PreviewSingletonView: View {
        @Query.Settings(PreviewSettingsModel().singleton)
        var singletonID: PersistentIdentifier?

        var body: some View {
            PreviewSingleton(id: singletonID).padding()
            TableEditor(
                factory: { PreviewModel() },
                editor: { $0.value = Int.random(in: 0..<100) }
            ) { item in
                cardRow(
                    item.id == singletonID
                        ? "Singleton Value" : "\(type(of: item).self)",
                    value: "\(item.value)"
                )
            }
            .cornerRadius(25)
        }
    }
#endif

#Preview {
    PreviewSingletonView()
        .modelContainer(
            for: PreviewModel.self, inMemory: true,
            isAutosaveEnabled: false
        )
        .preferredColorScheme(.dark)
        .resetSettings()
}
