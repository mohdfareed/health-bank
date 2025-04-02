import SwiftData
import SwiftUI

#if DEBUG
    struct PreviewSettingsModel: Settings {
        let first: Bool?
        let second: Bool = false
        let singleton: PersistentIdentifier?
        init() {}
    }

    struct PreviewSettings: View {
        @Query.Settings(\PreviewSettingsModel.first)
        var first: Bool?

        var body: some View {
            VStack {
                Toggle(isOn: $first.defaulted(to: false)) {
                    Text("Enable Feature A")
                }
                Divider()
                HStack {
                    Text("Feature A Status:")
                    switch self.first {
                    case true:
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.headline)
                    case false:
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                            .font(.headline)
                    case nil:
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.headline)
                    default:
                        Image(systemName: "ant.circle.fill")
                            .foregroundStyle(.purple)
                            .font(.headline)
                    }
                }
            }
            .padding()
            .background(.background.secondary)
            .cornerRadius(25)
            .padding()
        }
    }
#endif

#Preview {
    PreviewSettings()
        .modelContainer(for: PreviewModel.self, inMemory: true)
        .preferredColorScheme(.dark)
}
