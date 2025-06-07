import SwiftUI

// REVIEW: animations

struct RecordRow<R, U, S, Destination>: View
where R: HealthDate, U: Dimension, S: View, Destination: View {
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
        NavigationLink {
            destination()
        } label: {
            LabeledContent {
                record.source.icon?.asText.foregroundStyle(record.source.color)
            } label: {
                DetailedRow(image: field.image, tint: field.tint) {
                    let value = measurement.value.formatted(field.formatter)
                    let unit = Text(measurement.unit.symbol)
                        .textScale(.secondary)
                    Text("\(value) \(unit)")
                } subtitle: {
                    DateView(date: record.date)
                } details: {
                    subtitle()
                }
            }
        }
    }
}

struct DateView: View {
    let date: Date?
    var body: some View {
        if let relativeDate = relativeDate {
            Text(relativeDate)
        }
    }

    var relativeDate: String? {
        guard let date = date else {
            return nil
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.dateTimeStyle = .numeric

        return formatter.localizedString(
            for: date, relativeTo: Date.now
        )
    }
}

struct ValueView<Unit: Dimension>: View {
    @LocalizedMeasurement var measurement: Measurement<Unit>
    let icon: Image?
    let tint: Color?
    let format: FloatingPointFormatStyle<Double>

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            icon?.asText.foregroundStyle(tint ?? .primary)
            Text(
                measurement.formatted(
                    .measurement(
                        width: .narrow, usage: $measurement.definition.usage,
                        numberFormatStyle: format
                    )
                )
            )
        }
    }
}
