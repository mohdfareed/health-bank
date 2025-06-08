import SwiftData
import SwiftUI

struct HealthDataView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var activeDataModel: HealthDataModel? = nil
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(HealthDataModel.allCases, id: \.self) { dataModel in
                NavigationLink(value: dataModel) {
                    Label {
                        HStack {
                            Text(String(localized: dataModel.uiDefinition.title))
                                .font(.headline)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .font(.headline)
                                .imageScale(.medium)
                                .foregroundStyle(Color.accent)
                                .onTapGesture {
                                    activeDataModel = dataModel
                                }
                        }
                    } icon: {
                        dataModel.uiDefinition.icon
                            .foregroundStyle(dataModel.uiDefinition.color)
                    }
                }
                .foregroundStyle(.primary)
            }
            .navigationTitle("Health Data")
            .navigationDestination(for: HealthDataModel.self) {
                categoryView(for: $0)
            }
        }

        .sheet(item: $activeDataModel) { dataModel in
            NavigationStack {
                createRecordSheet(for: dataModel)
            }
        }
    }

    @ViewBuilder private func createRecordSheet(for dataModel: HealthDataModel) -> some View {
        dataModel.createNewRecordForm()
    }

    @ViewBuilder private func categoryView(
        for dataModel: HealthDataModel
    ) -> some View {
        switch dataModel {
        case .calorie:
            CategoryView<DietaryCalorie>(dataModel)
        case .activity:
            CategoryView<ActiveEnergy>(dataModel)
        case .weight:
            CategoryView<Weight>(dataModel)
        }
    }

    private struct CategoryAddMenu: View {
        let action: (HealthDataModel) -> Void
        init(_ action: @escaping (HealthDataModel) -> Void) {
            self.action = action
        }

        var body: some View {
            Menu {
                ForEach(
                    HealthDataModel.allCases, id: \.self
                ) { dataModel in
                    Button(action: { action(dataModel) }) {
                        Label {
                            Text(String(localized: dataModel.uiDefinition.title))
                        } icon: {
                            dataModel.uiDefinition.icon
                        }
                    }
                }
            } label: {
                Label("Log Data", systemImage: "plus.circle")
            }
        }
    }
}
