import SwiftUI

// RecordView no longer needs Record to be Equatable.
// The parent view is responsible for managing state and changes.
public struct RecordView<Record: DataRecord, FieldsContent: View>: View {
    let title: LocalizedStringKey
    var record: Record
    let fieldsContent: (Bool) -> FieldsContent

    @State private var editDate: Date
    @State private var isEditing: Bool = false

    public init(
        _ record: Record, title: LocalizedStringKey,
        @ViewBuilder fieldsContent: @escaping (Bool) -> FieldsContent,
    ) {
        self.title = title
        self.record = record
        self.fieldsContent = fieldsContent
        self._editDate = State(initialValue: record.date)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()

                if isEditing {
                    Button {
                        withAnimation {
                            isEditing = false
                        }
                    } label: {
                        Image.saveIcon.foregroundStyle(.green)
                    }
                } else if record.source == .local {
                    Button {
                        withAnimation {
                            editDate = record.date
                            isEditing = true
                        }
                    } label: {
                        Image.editIcon.foregroundStyle(.blue)
                    }
                }

                record.source.icon
                    .foregroundStyle(record.source.color)
                    .imageScale(.small)
            }
            .padding(.bottom, 4)

            fieldsContent(isEditing)

            Divider()
            HStack {
                Spacer()
                Image.dateIcon.foregroundStyle(.gray)
                if isEditing {
                    DatePicker(
                        selection: $editDate,
                        displayedComponents: [.date, .hourAndMinute]
                    ) {}
                    .datePickerStyle(.compact)
                    .foregroundColor(.primary)
                    .labelsHidden()
                } else {
                    Text(record.date, style: .date)
                    Text(record.date, style: .time)
                }
                Spacer()
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .animation(.default, value: isEditing)
    }
}

// MARK: Preview
// ============================================================================

struct RecordView_Preview: View {
    @State private var weight1: Weight = .init(
        date: Date(), weight: 78, source: .local
    )
    @State private var weight2: Weight = .init(
        date: Date(), weight: 68, source: .healthKit
    )

    var body: some View {
        VStack {
            RecordView(weight1, title: "Weight Record 1") {
                MeasurementField(
                    LocalizedMeasurement(
                        baseValue: $weight1.weight,
                        definition: Weight.unit
                    ),
                    vm: MeasurementFieldVM(
                        title: Text("Weight"),
                        image: Image.weight,
                        color: .blue,
                        fractions: 2
                    ),
                    editable: $0
                )
            }
            .modifier(CardStyle())

            RecordView(weight2, title: "Weight Record 2") {
                MeasurementField(
                    LocalizedMeasurement(
                        baseValue: $weight2.weight,
                        definition: Weight.unit
                    ),
                    vm: MeasurementFieldVM(
                        title: Text("Weight"),
                        image: Image.weight,
                        color: .blue,
                        fractions: 2
                    ),
                    editable: $0
                )
            }
            .modifier(CardStyle())
        }
        .navigationTitle("Weight Records")
        .padding()
    }
}

#Preview {
    RecordView_Preview()
}
