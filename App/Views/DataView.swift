import SwiftData
import SwiftUI

struct HealthDataView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    HealthDataCards()
                }
                .padding()
            }

            .navigationTitle("Health Data")
            .navigationDestination(for: HealthDataModel.self) {
                $0.recordList
            }
        }
    }
}

struct HealthDataCards: View {
    @Environment(\.modelContext) private var context: ModelContext

    var body: some View {
        ForEach(HealthDataModel.allCases, id: \.self) { model in
            NavigationLink(value: model) {
                LabeledContent {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .font(.footnote.bold())
                } label: {
                    Label {
                        Text(String(localized: model.definition.title))
                            .font(.title2)
                        Spacer()
                    } icon: {
                        model.definition.icon
                            .font(.largeTitle)
                            .foregroundStyle(model.definition.color)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }

            .buttonBorderShape(.capsule)
            .transform {
                if #available(iOS 26, macOS 26, watchOS 26, *) {
                    $0.glassEffect(
                        .regular,
                        in: .buttonBorder
                    )
                    .buttonStyle(.glass)
                } else {
                    $0.buttonStyle(.bordered)
                }
            }
        }
    }
}
