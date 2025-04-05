import SwiftData
import SwiftUI

struct PreviewSettings: View {
    let title: String
    let key: Settings<Bool>

    @Query.Settings<Bool> var query: Bool?
    var indicator: Bool? {
        UserDefaults.standard.get(self.key)
    }

    init(_ title: String, key: Settings<Bool>) {
        self.title = title
        self.key = key
        self._query = SettingsQuery(key)
    }

    var body: some View {
        VStack {
            HStack {
                Text(self.title).font(.headline)
                Spacer()
                Self.statusIndicator(self.query ?? false)
            }

            Divider()
            Toggle(isOn: $query.defaulted(to: false)) { Text("Editor") }
            Divider()

            HStack {
                Text("Indicator")
                Spacer()
                Self.statusIndicator(self.indicator ?? false)
            }
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
        static var first: Settings<Bool> { .init("First", default: false) }
        static let second: Settings<Bool> = .init("Second", default: nil)
        let third: Settings<Bool> = .init("Second", default: false)
        let singleton: Settings<PersistentIdentifier> = .init("Second")
        init() {}
    }

    struct PreviewSettingsView: View {
        init() {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }

        var body: some View {
            Group {
                PreviewSettings("Settings", key: PreviewSettingsModel.first)
            }.padding(.horizontal)

            HStack {
                Text("External Indicator").font(.headline).padding(.horizontal)
                Spacer()
                PreviewSettings.statusIndicator(
                    UserDefaults.standard.get(PreviewSettingsModel.first)
                ).padding(.horizontal)
            }.padding(.horizontal)

            Group {
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
