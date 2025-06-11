import HealthKit
import SwiftData
import SwiftUI

/// A view that displays records of a specific type with source filtering.
struct RecordList<T: HealthData>: View {
    @Environment(\.healthKit) private var healthKit: HealthKitService
    @DataQuery var records: [T]

    @State private var isCreating = false

    private let dataModel: HealthDataModel<T>
    private let definition: HealthRecordDefinition<T, AnyView, AnyView>

    init(_ dataModel: HealthDataModel<T>) {
        self.dataModel = dataModel
        self.definition = dataModel.definition

        // Use the query method from HealthDataModel extension (no filtering at query level)
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
                definition.formContent(T.init())
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

private struct RecordListRow<T: HealthData>: View {
    @AppLocale private var locale
    var record: T
    let definition: HealthRecordDefinition<T, AnyView, AnyView>

    var body: some View {
        NavigationLink {
            definition.formContent(record)
                .navigationTitle(String(localized: definition.title))
                .scrollDismissesKeyboard(.immediately)
        } label: {
            LabeledContent {
                record.source.icon.asText
                    .foregroundColor(Color.accent)
                    .font(.caption2)
            } label: {
                definition.rowContent(record)
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
