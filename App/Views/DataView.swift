import SwiftData
import SwiftUI

struct HealthDataView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var activeDataModel: HealthDataModel? = nil
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
                categoryView(for: $0)
            }
        }

        .sheet(item: $activeDataModel) { dataModel in
            NavigationStack {
                dataModel.createNewRecordForm()
            }
        }
    }

    @ViewBuilder private func categoryView(
        for dataModel: HealthDataModel
    ) -> some View {
        switch dataModel {
        case .calorie:
            RecordList<DietaryCalorie>(dataModel)
        case .weight:
            RecordList<Weight>(dataModel)
        }
    }
}

struct HealthDataCards: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var activeDataModel: HealthDataModel? = nil
    @Binding var navigationPath: NavigationPath

    var body: some View {
        ForEach(HealthDataModel.allCases, id: \.self) { model in
            Button {
                navigationPath.append(model)
            } label: {
                VStack(spacing: 12) {
                    model.uiDefinition.icon
                        .font(.system(size: 60))
                    Text(String(localized: model.uiDefinition.title))
                        .multilineTextAlignment(.center)
                        .textScale(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .aspectRatio(0.8, contentMode: .fill)

            .transform {
                if #available(iOS 26, macOS 26, watchOS 26, *) {
                    $0.glassEffect(
                        .regular.tint(model.uiDefinition.color),
                        in: .buttonBorder
                    )
                    .buttonStyle(.glass)
                } else {
                    $0
                        .buttonStyle(.bordered)
                        .foregroundStyle(model.uiDefinition.color)
                }
            }
            .buttonBorderShape(.roundedRectangle)
        }
    }
}
