import SwiftData
import SwiftUI

struct PreviewSettings: View {
    @Query.Settings<Bool?> var key: Bool?
    init(key: SettingsKey<Bool?>) { self._key = SettingsQuery(key) }
    init(key: SettingsKey<Bool>) {
        self._key = SettingsQuery(SettingsKey(key.id, default: key.default))
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Settings").font(.largeTitle)
                Spacer()
            }
            Divider()
            Toggle(isOn: $key.defaulted(to: false)) { Text("Editor") }
            Divider()
            status("Viewer", status: self.key)
        }
        .padding()
        .background(.background.secondary)
        .cornerRadius(25)
    }

    func status(_ message: String, status: Bool?) -> some View {
        HStack {
            Text(message)
            Spacer()

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
}

#if DEBUG
    struct PreviewSettingsModel {
        static var first: SettingsKey<Bool> { .init("First", default: false) }
        static let second: SettingsKey<Bool?> = .init("Second")
        let third: SettingsKey<Bool?> = .init("Second", default: false)
        let singleton: SettingsKey<PersistentIdentifier?> = SettingsKey("Second")
        init() {}
    }

    struct PreviewSettingsView: View {
        @Query.Settings(PreviewSettingsModel.first)
        var first: Bool
        @Query.Settings(PreviewSettingsModel.second)
        var second: Bool?
        @Query.Settings(PreviewSettingsModel().third)
        var third: Bool?

        var body: some View {
            VStack {
                PreviewSettings(key: PreviewSettingsModel.first)
                PreviewSettings(key: PreviewSettingsModel.second)
                PreviewSettings(key: PreviewSettingsModel().third)
            }
            .padding()
        }
    }
#endif

#Preview {
    PreviewSettingsView()
        .modelContainer(for: PreviewModel.self, inMemory: true)
        .preferredColorScheme(.dark).padding()
        .resetSettings()
    PreviewSettingsView()
        .modelContainer(for: PreviewModel.self, inMemory: true)
        .preferredColorScheme(.dark).padding()
        .resetSettings()
}
