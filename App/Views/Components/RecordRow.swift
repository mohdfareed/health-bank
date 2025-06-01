import SwiftUI

// REVIEW: animations

struct RecordRow<R, U, S, Destination>: View
where R: HealthRecord, U: Dimension, S: View, Destination: View {
    let record: R
    let field: RecordFieldDefinition<U>
    @LocalizedMeasurement var measurement: Measurement<U>

    @ViewBuilder let subtitle: () -> S?
    @ViewBuilder let destination: () -> Destination

    init(
        record: R, field: RecordFieldDefinition<U>,
        measurement: LocalizedMeasurement<U>,
        @ViewBuilder subtitle: @escaping () -> S,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.record = record
        self.field = field
        self._measurement = measurement
        self.subtitle = subtitle
        self.destination = destination
    }

    var body: some View {
        NavigationLink(destination: destination()) {
            DetailedRow(image: field.image, tint: field.tint) {
                let unit = Text(measurement.unit.symbol).textScale(.secondary)
                Text("\(measurement.value.formatted(field.formatter)) \(unit)")
            } subtitle: {
                DateView(date: record.date)
            } details: {
                subtitle()
            } content: {
                record.source.icon?.asText.foregroundStyle(record.source.color)
            }
        }
    }
}
