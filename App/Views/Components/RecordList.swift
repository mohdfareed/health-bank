import HealthKit
import SwiftData
import SwiftUI

/// A view that displays records of a specific type with source filtering.
struct RecordList<T: HealthData>: View {
    @Environment(\.healthKit) private var healthKit: HealthKitService
    @DataQuery var records: [T]

    @State private var isCreating = false
    @State var binding: any HealthData = T.init()

    private let dataModel: HealthDataModel
    private let definition: HealthRecordDefinition

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
        .onChange(of: isCreating) {
            if !isCreating {
                runTask($records.reload)
            }
        }

        .toolbar {
            ToolbarItem {
                Button("Add", systemImage: "plus") {
                    isCreating = true
                }
            }
        }
        .toolbarTitleDisplayMode(.inline)

        .sheet(isPresented: $isCreating) {
            NavigationStack {
                definition.formView($binding)
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
    let definition: HealthRecordDefinition

    var body: some View {
        NavigationLink {
            definition.formView($record)
                .navigationTitle(String(localized: definition.title))
                .scrollDismissesKeyboard(.immediately)
        } label: {
            LabeledContent {
                record.source.icon.asText
                    .foregroundColor(Color.accent)
                    .font(.caption2)
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
