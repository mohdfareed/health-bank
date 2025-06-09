import HealthKit
import SwiftData
import SwiftUI

/// A view that displays records of a specific type with source filtering.
struct RecordList<T: HealthData>: View {
    @Environment(\.healthKit) private var healthKit: HealthKitService
    @DataQuery var records: [T]
    @State private var isAddingRecord = false

    private let dataModel: HealthDataModel
    private let uiDefinition: any HealthRecordUIDefinition

    init(_ dataModel: HealthDataModel) {
        self.dataModel = dataModel
        self.uiDefinition = dataModel.uiDefinition

        // Use the query method from HealthDataModel extension (no filtering at query level)
        let query: any HealthQuery<T> = dataModel.query()
        _records = DataQuery(
            query, from: .distantPast, to: .distantFuture
        )
    }

    var body: some View {
        List {
            ForEach(records) { record in
                GenericRecordRow(record: record, dataModel: dataModel, uiDefinition: uiDefinition)
            }
            loadMoreButton()
        }
        .navigationTitle(String(localized: uiDefinition.title))
        .animation(.default, value: $records.isLoading)
        .animation(.default, value: $records.isExhausted)

        .onAppear {
            Task {
                await $records.loadNextPage()
            }
        }
        .refreshable {
            await $records.reload()
        }

        .toolbar {
            toolbar()
        }
        .toolbarTitleDisplayMode(.inline)

        .sheet(isPresented: $isAddingRecord) {
            NavigationStack {
                createRecordSheet()
            }
        }

        .onChange(of: isAddingRecord) { _, new in
            if !new {  // Refresh data when adding a new record
                Task { await $records.reload() }
            }
        }
    }

    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem {
            Button("Add", systemImage: "plus") {
                isAddingRecord = true
            }
        }
    }

    @ViewBuilder private func loadMoreButton() -> some View {
        if !$records.isLoading && !$records.isExhausted {
            Button("Load More") {
                Task { await $records.loadNextPage() }
            }
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
        }

        if $records.isLoading {
            HStack {
                Spacer()
                ProgressView().scaleEffect(0.8)
                Spacer()
            }
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder private func createRecordSheet() -> some View {
        dataModel.createNewRecordForm()
    }
}

/// A generic record row that works with any HealthRecordUIDefinition
private struct GenericRecordRow<T: HealthData>: View {
    @AppLocale private var locale

    let record: T
    let dataModel: HealthDataModel
    let uiDefinition: any HealthRecordUIDefinition

    var body: some View {
        NavigationLink {
            createEditRecordSheet()
        } label: {
            LabeledContent {
                record.source.icon.asText
                    .foregroundColor(Color.accent)
                    .font(.caption2)
            } label: {
                DetailedRow(image: nil, tint: nil) {
                    dataModel.createMainValue(record)
                } subtitle: {
                    Text(formatTime(record.date))
                        .foregroundStyle(.tertiary)
                        .font(.footnote)
                } details: {
                    dataModel.createRowSubtitle(record)
                        .textScale(.secondary)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder private func createEditRecordSheet() -> some View {
        dataModel.createEditRecordForm(record)
    }

    func formatTime(_ date: Date) -> String {
        // 1) Create a formatter for the "2 days ago" part:
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.calendar = locale.calendar
        formatter.dateTimeStyle = .named  // “2 days ago at 3:45 PM”
        formatter.unitsStyle = .full  // “2 d. ago” vs “2 days ago”
        formatter.formattingContext = .dynamic
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
