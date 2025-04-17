import SwiftData
import SwiftUI

struct PreviewEnvironment: View {
    let title: String
    @Environment(\.previewState) var model: PreviewStateModel

    var state: Binding<Bool> {
        .init(
            get: { self.model.state },
            set: { self.model.state = $0 }
        )
    }

    var body: some View {
        VStack {
            HStack {
                Text(self.title).font(.headline)
                Spacer()
                Self.statusIndicator(self.model.state)
            }
            Divider()
            Toggle(isOn: self.state) { Text("Status") }
        }
        .animation(.default, value: self.model.state)
    }

    static func statusIndicator(_ status: Bool?) -> some View {
        switch status {
        case true:
            Image(systemName: "checkmark.circle.fill")
                .font(.headline).foregroundStyle(.green)
                .padding(.trailing, 4)
        case false:
            Image(systemName: "xmark.circle.fill")
                .font(.headline).foregroundStyle(.red)
                .padding(.trailing, 4)
        case nil:
            Image(systemName: "questionmark.circle.fill")
                .font(.headline).foregroundStyle(.gray)
                .padding(.trailing, 4)
        default:
            Image(systemName: "ant.circle.fill")
                .font(.headline).foregroundStyle(.purple)
                .padding(.trailing, 4)
        }
    }
}

#if DEBUG
    @Observable class PreviewStateModel {
        var state: Bool = false
    }
    extension EnvironmentValues {
        @Entry var previewState: PreviewStateModel = .init()
    }

    // struct PreviewStateStorage {
    //     // @Environment(\.previewState) var model: PreviewStateModel
    //     var state: Bool {
    //         get { self.model.state }
    //         nonmutating set { self.model.state = newValue }
    //     }
    // }

    struct PreviewEnvironmentView: View {
        @Environment(\.previewState) var model: PreviewStateModel
        // var modelStorage: PreviewStateStorage = PreviewStateStorage()

        var body: some View {
            NavigationView {
                List {
                    Section {
                        PreviewEnvironment(title: "Environment 1")
                    }
                    Section {
                        PreviewEnvironment(title: "Environment 2")
                    }

                    HStack {
                        Spacer()
                        Button("Toggle State") {
                            print("State (old): \(self.model.state)")
                            self.model.state.toggle()
                            // self.modelStorage.state.toggle()
                            // PreviewStateStorage().state.toggle()
                            print("State (new): \(self.model.state)")
                        }
                        .tint(self.model.state ? .red : .green)
                        Spacer()
                    }
                }
                .navigationTitle("Environment Preview")
            }
        }
    }
#endif

#Preview {
    PreviewEnvironmentView()
        .environment(\.previewState, .init())
        .modelContainer(
            for: PreviewModel.self, inMemory: true,
            isAutosaveEnabled: false
        )
        .preferredColorScheme(.dark)
}
