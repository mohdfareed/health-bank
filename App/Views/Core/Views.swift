import SwiftData
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

    var measFormat: Measurement<Unit>.FormatStyle {
        .measurement(
            width: .wide, usage: .asProvided,
            numberFormatStyle: format
        )
    }

    var body: some View {
        HStack(alignment: .center) {
            TextField("", value: $measurement.value, format: format)
                .multilineTextAlignment(.trailing)

            if $measurement.availableUnits().count > 1 {
                picker.frame(minWidth: 8, maxWidth: 8).fixedSize()
            } else {
                Spacer(minLength: 16).fixedSize()
            }
        }
    }

    var picker: some View {
        Picker("", selection: $measurement.unit) {
            ForEach($measurement.availableUnits(), id: \.self) {
                Text(
                    measurement.converted(to: $0).formatted(
                        .measurement(
                            width: .wide, usage: .asProvided,
                            numberFormatStyle: format
                        )
                    ).localizedCapitalized
                ).tag($0)
            }
        }
        .labelsHidden()
    }
}

struct MeasurementRow<Unit: Dimension>: View {
    @LocalizedMeasurement var measurement: Measurement<Unit>
    let title: String.LocalizationValue
    let image: Image?
    let tint: Color?

    let computed: Double?
    let format: FloatingPointFormatStyle<Double>

    var body: some View {
        DetailedRow(
            title: Text(String(localized: title)),
            subtitle: Text(measurement.unit.symbol).textScale(.secondary),
            details: $measurement.computedText(
                computed, format: format
            ),
            image: image, tint: tint
        ) {
            MeasurementField(
                measurement: $measurement,
                format: format
            )
        }
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
        let icon = Text(Image(systemName: "function")).font(.footnote.bold())
        return Text("\(icon): \(text)").textScale(.secondary)
    }
}

// MARK: Preview
// ============================================================================

struct MeasurementRow_Previews: View {
    @Query.Singleton() private var budgets: Budgets
    @State private var weight = Weight(70.0)
    @State private var toggle = false

    var body: some View {
        MeasurementRow(
            measurement: .init(
                $budgets.calories,
                definition: .init(.kilocalories, usage: .food)
            ),
            title: "Calories", image: Image.calories, tint: .orange,
            computed: 2000, format: .number.precision(.fractionLength(0)),
        )

        MeasurementRow(
            measurement: weight.measurement,
            title: "Weight", image: Image.weight, tint: .purple,
            computed: nil, format: .number.precision(.fractionLength(2)),
        )

        DetailedRow(
            title: Text("Primary Title"),
            subtitle: Text("Optional Subtitle."),
            details: Text("Optional Caption."),
            image: Image(systemName: "heart.fill"), tint: .healthKit
        ) {
            Toggle("", isOn: $toggle)
        }
    }
}

#Preview {
    List {
        MeasurementRow_Previews()
            .modelContainer(
                for: [DietaryEnergy.self, Weight.self],
                inMemory: true
            )
    }
}
