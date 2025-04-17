import SwiftData
import SwiftUI

struct PreviewSingleton<T: Singleton>: View {
    private let editor: ((T) -> Void)?
    @Query.Singleton var model: T?

    init(
        _ predicate: Predicate<T>?, editor: ((T) -> Void)? = nil
    ) {
        self._model = .init(.init(filter: predicate))
        self.editor = editor
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Singleton").font(.headline)
                Spacer()
            }.padding(.horizontal)

            if let model = self.model {
                PreviewModelEditor.card(
                    model: model,
                    editor: self.editor,
                ) { cardRow("Model", value: "\(type(of: $0))") }
                .animation(.default, value: self.model)
            } else {
                Text("No singleton found.")
                    .foregroundStyle(.red).padding()
            }
        }
        .animation(.default, value: self.model)
    }
}

#if DEBUG
    struct PreviewSingletonView: View {
        @Environment(\.modelContext) var context
        @Query.Settings(PreviewSettingsModel().singleton)
        var singletonID: PreviewSingletonKey?

        @AppStorage("singletonID")
        private var singletonIDStorage: PersistentIdentifier?

        var key: String? { singletonID?.rawValue }

        init() {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }

        var body: some View {
            HStack {
                Text("\(String(describing: self.singletonID))")
                    .font(.footnote).fontDesign(.monospaced)
                    .foregroundStyle(.secondary)
            }.padding(.horizontal)

            let key = self.key
            PreviewSingleton<PreviewModel>(
                #Predicate { $0.key == key },
                editor: {
                    self.singletonID = self.singletonID?.next ?? PreviewSingletonKey.first
                    $0.value = Int.random(in: 0..<100)
                }
            )

            PreviewTableEditor(
                factory: { PreviewModel() },
                editor: {
                    if self.key != $0.key {
                        $0.key = self.singletonID?.rawValue
                    }
                    self.singletonIDStorage = $0.persistentModelID
                    $0.value = Int.random(in: 0..<100)
                }
            ) { item in
                cardRow(
                    item.key == self.singletonID?.rawValue
                        ? "Singleton" : "\(type(of: item).self)",
                    value: "\(item.value)"
                )
                Divider()
                cardRow(
                    "Key",
                    value: "\(item.key ?? "")"
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
}
