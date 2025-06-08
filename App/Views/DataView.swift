import SwiftData
import SwiftUI

struct HealthDataView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var activeCategory: HealthRecordCategory? = nil
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(HealthRecordCategory.allCases) { category in
                NavigationLink(value: category) {
                    Label {
                        HStack {
                            Text(category.localized)
                                .font(.headline)
                            Spacer()
                            Image(systemName: "plus.circle")
                                .font(.headline)
                                .imageScale(.medium)
                                .foregroundStyle(Color.accent)
                                .onTapGesture {
                                    activeCategory = category
                                }
                        }
                    } icon: {
                        category.icon
                            .foregroundStyle(category.color)
                    }
                }
                .foregroundStyle(.primary)
            }
            .navigationTitle("Health Data")
            .navigationDestination(for: HealthRecordCategory.self) {
                categoryView(for: $0)
            }
        }

        .sheet(item: $activeCategory) { category in
            NavigationStack {
                category.recordSheet
            }
        }
    }

    @ViewBuilder private func categoryView(
        for category: HealthRecordCategory
    ) -> some View {
        switch category {
        case .dietary:
            CategoryView<DietaryCalorie>(category)
        case .active:
            CategoryView<ActiveEnergy>(category)
        case .weight:
            CategoryView<Weight>(category)
        }
    }

    private struct CategoryAddMenu: View {
        let action: (HealthRecordCategory) -> Void
        init(_ action: @escaping (HealthRecordCategory) -> Void) {
            self.action = action
        }

        var body: some View {
            Menu {
                ForEach(
                    HealthRecordCategory.allCases, id: \.self
                ) { category in
                    Button(action: { action(category) }) {
                        Label {
                            Text(category.localized)
                        } icon: {
                            category.icon
                        }
                    }
                }
            } label: {
                Label("Log Data", systemImage: "plus.circle")
            }
        }
    }
}
