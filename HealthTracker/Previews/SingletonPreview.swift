import SwiftData
import SwiftUI

struct PreviewSingleton<T: PersistentModel>: View {
    private let editor: ((T) -> Void)?
    @Query.Singleton var model: T?

    init(
        id: Predicate<T>?, editor: ((T) -> Void)? = nil
    ) {
        self._model = .init(id)
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
        var singletonID: SingletonKey?

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
                id: #Predicate { $0.key == key },
                editor: {
                    self.singletonID = self.singletonID?.next ?? SingletonKey.first
                    $0.value = Int.random(in: 0..<100)
                }
            )

            TableEditor(
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

@Model class Recipe {
    init() {}
}
struct RecipeList: View {
    @Environment(\.modelContext) var context
    @Query var recipes: [Recipe]
    @AppStorage("selectedID") var selectedRecipeID: Recipe.ID?

    var body: some View {
        Text("Selected Recipe ID: \(selectedRecipeID?.hashValue ?? 0)")
            .padding()
        HStack {
            Button("Add") {
                let recipe = Recipe()
                self.context.insert(recipe)
                try? self.context.save()
                // self.selectedRecipeID = recipe.persistentModelID
            }
            Button("Save") {
                // try! self.context.save()
            }
        }
        List(recipes) { recipe in
            Button(action: {
                print(self.selectedRecipeID?.hashValue ?? "nil")
                self.selectedRecipeID = recipe.id
                print(self.selectedRecipeID?.hashValue ?? "nil")
            }) {
                HStack {
                    Text("\(recipe.persistentModelID.hashValue)")
                        .font(.footnote).fontDesign(.monospaced).bold()
                    if self.selectedRecipeID == recipe.persistentModelID {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.headline)
                    }
                }
            }
        }
    }
}

#Preview {
    // RecipeList()
    PreviewSingletonView()
        .modelContainer(
            for: PreviewModel.self, inMemory: true,
            isAutosaveEnabled: false
        )
        .preferredColorScheme(.dark)
}
