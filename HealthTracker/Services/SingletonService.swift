import Foundation
import SwiftData
import SwiftUI

/// A property wrapper to fetch a singleton model. If multiple models are
/// found, the first one is returned, ordered by the model's ID.
@MainActor @propertyWrapper
struct SingletonQuery<Model: PersistentModel>: DynamicProperty {
    @Query private var models: [Model]

    init() {
        self._models = Query(sort: \.persistentModelID, order: .forward)
    }

    init(_ id: PersistentIdentifier) {
        self._models = Query(
            filter: #Predicate<Model> { $0.persistentModelID == id },
            sort: \.persistentModelID, order: .forward
        )
    }

    init(_ predicate: Predicate<Model>) {
        self._models = Query(
            filter: predicate, sort: \.id, order: .forward
        )
    }

    var wrappedValue: Model? {
        self.models.first
    }
}

extension Query {
    typealias Singleton = SingletonQuery
}

// MARK: Preview

// #if DEBUG
//     @Model final class SingletonPreviewModel {
//         @Attribute(.unique) var id: UUID = UUID()
//         var value: Int = 0
//         init() {}
//     }

//     struct SingletonPreview: View {
//         @Environment(\.modelContext) var context
//             @Query.Singleton var model: SingletonPreviewModel?

//         var body: some View {
//             NavigationView {
//                 List {
//                     if let model = model {
//                         row("ID", value: model.id.uuidString)
//                         HStack {
//                             row("Value", value: "\(model.value)")
//                             Spacer()
//                             editButton(model)
//                         }

//                     } else {
//                         HStack {
//                             Spacer()
//                             Text("No model found").foregroundStyle(.red)
//                             Spacer()
//                         }
//                     }
//                 }
//                 .navigationTitle("Editor")
//                 .toolbar {
//                     ToolbarItemGroup(placement: .primaryAction) { addButton() }
//                     ToolbarItemGroup(placement: .cancellationAction) {
//                         saveButton()
//                     }
//                 }
//             }
//         }

//         private func row(_ name: String, value: String) -> some View {
//             HStack {
//                 Text(name).foregroundStyle(.primary)
//                 Spacer()
//                 Text(value).foregroundColor(.secondary)
//             }
//         }

//         private func addButton() -> some View {
//             AnyView(
//                 Button(action: {
//                     let newModel = SingletonPreviewModel()
//                     newModel.value = Int.random(in: 1...100)
//                     context.insert(newModel)
//                     do {
//                         try context.save()
//                     } catch { print("Failed to save model: \(error)") }
//                 }) { Image(systemName: "plus") }
//             )
//         }

//         private func saveButton() -> some View {
//             AnyView(
//                 Button(action: {
//                     do {
//                         try context.save()
//                     } catch {
//                         print("Failed to save: \(error)")
//                     }
//                 }) { Image(systemName: "square.and.arrow.down") }
//             )
//         }

//         private func editButton(_ item: SingletonPreviewModel) -> some View {
//             AnyView(
//                 Button(action: {
//                     item.value += 1
//                 }) { Image(systemName: "pencil").tint(.purple) }
//             )
//         }
//     }
// #endif

// #Preview {
//     SingletonPreview()
//         .modelContainer(for: SingletonPreviewModel.self, inMemory: true)
//         .preferredColorScheme(.dark)
// }
