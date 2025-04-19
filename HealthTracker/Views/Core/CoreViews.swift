import SwiftUI

struct MeasurementField<D: Dimension>: View {
    let text: String
    let image: String?
    let color: Color
    let fractions: Int  // the number of digits
    let validator: (Double?) -> Text?

    @LocalizedMeasurement
    var measurement: Measurement<D>

    var body: some View {
        HStack {
            MeasurementLabel(
                text, unit: self.$measurement.localizedUnit,
                image: image, color: color
            )

            TextField(
                value: self.$measurement.value,
                format: .number.precision(.fractionLength(self.fractions)),
                prompt: self.validator(self.measurement.value)
            ) {}
            .multilineTextAlignment(.trailing)

            Picker(
                "",
                selection: self.$measurement.unit.defaulted(
                    to: self.$measurement.localizedUnit
                )
            ) {
                ForEach(self.$measurement.definition.alts, id: \.self) { u in
                    Text(
                        self.measurement.converted(to: u).formatted(
                            self.$measurement.style(u)
                        )
                    ).tag(u)
                }
            }
            .labelsHidden()
            .frame(maxWidth: 16)
        }
    }
}

struct MeasurementLabel<D: Dimension>: View {
    let text: String
    let image: String?
    let unit: Unit?
    let color: Color

    init(
        _ text: String, unit: Unit?,
        image: String? = nil, color: Color = .primary,
    ) {
        self.text = text
        self.image = image
        self.color = color
        self.unit = unit
    }

    var body: some View {
        Label {
            HStack {
                Text(self.text).lineLimit(1).fixedSize()
                if let unit = self.unit {
                    Text(unit.symbol).lineLimit(1).fixedSize()
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
        } icon: {
            if let image = self.image {
                Image(systemName: image).symbolVariant(.fill).tint(color)
            }
        }
    }
}
