import HealthVaultsShared
import SwiftData
import SwiftUI

struct HealthDataView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                HealthDataCards()
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
        ForEach(Array(HealthDataModel.allCases.enumerated()), id: \.1) { index, model in
            if index == 0 {
                Section("") {
                    recordsLink(for: model)
                }
            } else {
                Section {
                    recordsLink(for: model)
                }
            }
        }
    }

    @ViewBuilder
    private func recordsLink(for model: HealthDataModel) -> some View {
        NavigationLink(value: model) {
            Label {
                Text(String(localized: model.definition.title))
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
                    .fontDesign(.rounded)
                    .padding(.leading, 4)
            } icon: {
                model.definition.icon
                    .font(.largeTitle)
                    .foregroundStyle(model.definition.color)
            }
            .padding()
        }
    }
}
