import SwiftData
import SwiftUI

struct HealthDataView: View {
    @Environment(\.modelContext) private var context: ModelContext
    @State private var activeCategory: HealthRecordCategory? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(
                    HealthRecordCategory.allCases, id: \.self
                ) { category in
                    NavigationLink(
                        destination: categoryView(for: category)
                    ) {
                        Label {
                            HStack {
                                Text(category.localized)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .font(.headline)
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
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Health Records")
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
        case .resting:
            CategoryView<RestingEnergy>(category)
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
                Label("Log Record", systemImage: "plus.circle")
            }
        }
    }
}
