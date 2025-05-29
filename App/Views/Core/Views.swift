import SwiftUI

struct DetailedRow<Content: View>: View {
    let title: Text
    let subtitle: Text?
    let details: Text?
    let image: Image?
    let tint: Color?

    @ViewBuilder var content: () -> Content

    var body: some View {
        Label {
            HStack(spacing: 8) {
                VStack(alignment: .leading) {
                    HStack {
                        title
                        if let subtitle = subtitle {
                            Text("•  \(subtitle)").textScale(.secondary)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let details = details {
                        details.textScale(.secondary)
                            .foregroundStyle(.secondary)
                    }
                }
                .truncationMode(.tail)
                .lineLimit(1)

                Spacer()
                content().fixedSize()
            }
        } icon: {
            if let image = image {
                image.foregroundStyle(tint ?? .primary)
            }
        }
    }
}

struct MeasurementField<Unit: Dimension>: View {
    @LocalizedMeasurement var measurement: Measurement<Unit>
    let format: FloatingPointFormatStyle<Double>

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            TextField("", value: $measurement.value, format: format)
                .multilineTextAlignment(.trailing)
            unitsPicker
        }
    }

    var unitsPicker: some View {
        Picker("", selection: $measurement.unit) {
            ForEach($measurement.availableUnits(), id: \.self) {
                let label = measurement.converted(to: $0).formatted(
                    .measurement(
                        width: .abbreviated, usage: .asProvided,
                        numberFormatStyle: format
                    )
                ).localizedCapitalized

                if $0 != measurement.unit {
                    Text(label).tag($0 as Unit?)
                } else {
                    Text(measurement.unit.symbol).tag(nil as Unit?)
                }
            }
        }
        .labelsHidden()
    }
}

extension LocalizedMeasurement {
    func computedText(
        _ computed: Double?, format: FloatingPointFormatStyle<Double>
    ) -> Text? {
        guard let computed = computed else {
            return nil
        }

        guard computed != self.baseValue else {
            return nil
        }

        let measurement = Measurement(
            value: computed, unit: self.definition.baseUnit
        ).converted(to: self.unit.wrappedValue)

        let text = measurement.value.formatted(format)
        let icon = Text(Image(systemName: "function")).font(.caption)
        return Text("\(icon): \(text)").textScale(.secondary)
    }
}

// MARK: Preview
// ============================================================================

#Preview {
    VStack {
        DetailedRow(
            title: Text("Primary Title"),
            subtitle: Text("Optional Subtitle."),
            details: Text("Optional Caption."),
            image: Image(systemName: "heart.fill"), tint: .logoPrimary
        ) {
            MeasurementField(
                measurement: Weight(50).measurement,
                format: .number.precision(.fractionLength(0))
            )
        }

        DetailedRow(
            title: Text("Primary Title"),
            subtitle: Text("Optional Subtitle."),
            details: Text("Optional Caption."),
            image: Image(systemName: "heart.fill"), tint: .healthKit
        ) {
            Toggle("", isOn: .constant(true))
        }
    }
    .modifier(CardStyle())
    .padding()
}
