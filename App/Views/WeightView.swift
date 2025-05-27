import SwiftUI

struct WeightRecordView: View {  // Corrected: Conforms to View, not "some View"
    var title: LocalizedStringKey

    @Binding var record: Weight
    // newWeight is used by MeasurementField, which likely handles the edit-in-progress value.
    // The RecordView's simple mode will manage its own edit state for the overall card.
    @State private var newWeight: Double? = nil

    var body: some View {
        RecordView(
            record, title: title
        ) {
            MeasurementField(
                LocalizedMeasurement(
                    baseValue: $newWeight.defaulted(to: record.weight),
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
    }
}
