import SwiftData
import SwiftUI

struct HealthDataView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()), GridItem(.flexible()),
                    ], spacing: 16
                ) { HealthDataCards(navigationPath: $navigationPath) }
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
    @Binding var navigationPath: NavigationPath

    var body: some View {
        ForEach(HealthDataModel.allCases, id: \.self) { model in
            Button {
                navigationPath.append(model)
            } label: {
                VStack(spacing: 12) {
                    model.definition.icon
                        .font(.system(size: 60))
                    Text(String(localized: model.definition.title))
                        .multilineTextAlignment(.center)
                        .textScale(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .aspectRatio(0.8, contentMode: .fill)

            .transform {
                if #available(iOS 26, macOS 26, watchOS 26, *) {
                    $0.glassEffect(
                        .regular.tint(model.definition.color),
                        in: .buttonBorder
                    )
                    .buttonStyle(.glass)
                } else {
                    $0
                        .buttonStyle(.bordered)
                        .foregroundStyle(model.definition.color)
                }
            }
            .buttonBorderShape(.roundedRectangle)
        }
    }
}
