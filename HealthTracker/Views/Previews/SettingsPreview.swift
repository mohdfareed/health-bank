import SwiftData
import SwiftUI

struct PreviewSettings: View {
    let title: String
    @Query.Settings<Bool?> var query: Bool?

    init(_ title: String, key: Settings<Bool?>) {
        self.title = title
        self._query = AppStorage(key)
    }

    var body: some View {
        VStack {
            HStack {
                Text(self.title).font(.headline)
                Spacer()
                Self.statusIndicator(self.query ?? false)
            }
            Divider()
            Toggle(isOn: self.$query.defaulted(to: false)) { Text("Status") }
        }
        .padding()
        .background(.background.secondary)
        .cornerRadius(25)
        .animation(.default, value: self.query)
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
    struct PreviewSettingsModel {
        static var first: Settings<Bool?> { .init("First", default: false) }
        let singleton: Settings<PreviewSingletonKey?> = .init("Singleton", default: nil)
        init() {}
    }

    struct PreviewSettingsView: View {
        init() {
            UserDefaults.standard.removePersistentDomain(forName: appID)
        }

        var body: some View {
            VStack {
                PreviewSettings("Settings", key: PreviewSettingsModel.first)
                PreviewSettings("Preview", key: PreviewSettingsModel.first)
            }.padding(.horizontal)
        }
    }
#endif

#Preview {
    PreviewSettingsView()
        .modelContainer(
            for: PreviewModel.self, inMemory: true,
            isAutosaveEnabled: false
        )
        .preferredColorScheme(.dark)
}
