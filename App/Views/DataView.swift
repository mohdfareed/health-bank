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
                ) {
                    ForEach(HealthDataModel.allCases, id: \.self) { model in
                        Button {
                            navigationPath.append(model)
                        } label: {
                            VStack(spacing: 12) {
                                model.uiDefinition.icon
                                    .foregroundStyle(model.uiDefinition.color)
                                    .font(.system(size: 60))

                                Text(String(localized: model.uiDefinition.title))
                                    .textScale(.secondary)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .buttonStyle(.plain)
                            .aspectRatio(0.8, contentMode: .fill)
                            .background(
                                model.uiDefinition.color.opacity(0.05),
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                            .background(
                                .thinMaterial,
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                        }
                    }
                }
                .padding()
            }

            .overlay(alignment: .bottom) {
                // Menu button for creating new records
                CategoryAddMenu { dataModel in
                    activeDataModel = dataModel
                }
                .padding()
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
            RecordList<DietaryCalorie>(dataModel)
        case .weight:
            RecordList<Weight>(dataModel)
        }
    }

    private struct CategoryAddMenu: View {
        let action: (HealthDataModel) -> Void
        @State private var isAppeared = false

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
                Label("Add Data", systemImage: "plus.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 60))
                    .symbolEffect(.bounce, value: isAppeared)
            }
            .buttonStyle(.borderless)
            .onAppear {
                isAppeared.toggle()
            }
        }
    }
}
