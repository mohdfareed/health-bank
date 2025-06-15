import HealthKit
import SwiftData
import SwiftUI

/// A view that displays records of a specific type with source filtering.
struct RecordList<T: HealthData>: View {
    @DataQuery var records: [T]
    @State private var isCreating = false

    private let dataModel: HealthDataModel
    private let definition: RecordDefinition

    init(_ dataModel: HealthDataModel, for: T.Type) {
        self.dataModel = dataModel
        self.definition = dataModel.definition

        let query: any HealthQuery<T> = dataModel.query()
        _records = DataQuery(
            query, from: .distantPast, to: .distantFuture
        )
    }

    var body: some View {
        List {
            ForEach(records) { record in
                RecordListRow(record: record, definition: definition)
            }
            loadMoreButton()
        }
        .navigationTitle(String(localized: definition.title))
        .animation(.default, value: $records.isLoading)
        .animation(.default, value: $records.isExhausted)

        .onAppear {
            runTask($records.reload)
        }
        .refreshable {
            runTask($records.reload)
        }

        .toolbar {
            ToolbarItem {
                if #available(iOS 26, macOS 26, watchOS 26, *) {
                    Button("Add", systemImage: "plus") {
                        isCreating = true
                    }
                } else {
                    Button("Add", systemImage: "plus") {
                        isCreating = true
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                }

            }
        }

        .sheet(isPresented: $isCreating) {
            NavigationStack {
                dataModel.createForm(formType: .create)
            }
        }
    }

    @ViewBuilder private func loadMoreButton() -> some View {
        if !$records.isLoading && !$records.isExhausted {
            Button("Load More", systemImage: "arrow.down") {
                runTask($records.loadNextPage)
            }
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
        }

        if $records.isLoading {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
    }

    private func runTask(_ task: @escaping () async -> Void) {
        Task {
            await task()
        }
    }
}

private struct RecordListRow: View {
    @AppLocale private var locale
    @State var record: any HealthData
    let definition: RecordDefinition

    var body: some View {
        NavigationLink {
            let dataModel = HealthDataModel.from(record)
            dataModel.createForm(
                formType: record.source == .app ? .edit : .view,
                record: record
            )
        } label: {
            LabeledContent {
                HStack(alignment: .center, spacing: 8) {
                    Text(formatTime(record.date))
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                    record.source.icon.asText
                        .foregroundColor(Color.accent)
                        .font(.caption2)
                }
            } label: {
                definition.rowView(record)
            }
        }
    }

    func formatTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.calendar = locale.calendar
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        formatter.formattingContext = .dynamic
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: Add Buttons
// ============================================================================

struct AddMenu: View {
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
                        Text(
                            String(
                                localized: dataModel.definition.title
                            )
                        )
                    } icon: {
                        dataModel.definition.icon
                    }
                }
            }
        } label: {
            Button {
            } label: {
                Label("Add Data", systemImage: "plus")
                    .labelStyle(.iconOnly)
            }
        }
        .buttonBorderShape(.circle)
        .buttonStyle(.borderedProminent)
    }
}

@available(iOS 26, macOS 26, watchOS 26, *)
struct AddButton: View {
    @Environment(\.tabViewBottomAccessoryPlacement) var placement

    let definition: RecordDefinition
    let action: () -> Void

    init(_ definition: RecordDefinition, action: @escaping () -> Void) {
        self.definition = definition
        self.action = action
    }

    var body: some View {
        switch placement {
        case .inline:
            inlineButton
        case .expanded:
            expandedButton
        default:  // expanded
            let _ = AppLogger.new(for: self).warning(
                "Unsupported button placement: \(placement.debugDescription)"
            )
            expandedButton
        }
    }

    var inlineButton: some View {
        Button(action: { action() }) {
            definition.icon
        }
        .buttonStyle(.borderless)
        .labelStyle(.titleAndIcon)
        .foregroundStyle(definition.color)
        .padding(.horizontal)
    }

    var expandedButton: some View {
        Button(action: { action() }) {
            Label {
                Text(String(localized: definition.title))
            } icon: {
                definition.icon
            }
        }
        .glassEffect(
            .regular.tint(definition.color)
        )
        .buttonStyle(.glass)
        .labelStyle(.titleAndIcon)
        .padding(.horizontal)
    }
}
