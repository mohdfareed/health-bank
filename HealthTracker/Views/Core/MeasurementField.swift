import SwiftUI

// MARK: View
// ============================================================================

struct MeasurementField<D: Dimension>: View {
    @LocalizedMeasurement
    var measurement: Measurement<D>
    let computed: Double?
    let validator: (Double) -> Double

    let title: String
    let (image, color): (Image?, Color)
    let fractions: Int  // the number of digits

    init(
        _ measurement: LocalizedMeasurement<D>,
        title: String, image: Image? = nil, color: Color = .primary,
        computed: Double? = nil, fractions: Int = 0,
        validator: @escaping (Double) -> Double = { $0 }
    ) {
        self._measurement = measurement
        self.computed = computed
        self.validator = validator
        self.title = title
        self.image = image
        self.color = color
        self.fractions = fractions
    }

    var rawValue: Double {
        get { self.$measurement.value.wrappedValue }
        nonmutating set { self.$measurement.value.wrappedValue = newValue }
    }

    var body: some View {
        DataRow(
            title: Text(self.title), subtitle: computedText(),
            image: self.image, color: self.color
        ) {
            self.valueField()
            self.unitPicker()
        }
    }
}

// MARK: Components
// ============================================================================

extension MeasurementField {
    private func valueField() -> some View {
        TextField(
            value: self.$measurement.value,
            format: .number.precision(.fractionLength(self.fractions)),
            prompt: Text(String(localized: "Value"))
        ) {}
        .multilineTextAlignment(.trailing)
        .onChange(of: self.measurement.value) {
            self.rawValue = self.validator(rawValue)
        }
    }

    private func unitPicker() -> some View {
        Picker("", selection: self.$measurement.unit) {
            ForEach(self.$measurement.definition.alts, id: \.self) { u in
                let meas = self.measurement.converted(to: u)
                let format = Measurement<D>.FormatStyle(
                    width: .wide,
                    numberFormatStyle: .number.precision(
                        .fractionLength(self.fractions)
                    )
                )

                let style = self.$measurement.style(u, base: format)
                Text(meas.formatted(style).localizedCapitalized).tag(u)
            }
        }.labelsHidden().frame(maxWidth: 16)
    }

    private func computedText() -> Text {
        let unit = self.$measurement.unit.wrappedValue.symbol
        guard let computed = self.computed else { return Text(unit) }
        guard computed != self.rawValue else { return Text(unit) }

        let measurement = Measurement(
            value: computed, unit: self.$measurement.definition.baseUnit
        ).converted(to: self.$measurement.unit.wrappedValue)
        let value = measurement.value.formatted(
            .number.precision(.fractionLength(self.fractions))
        )

        let icon = Text(Image(systemName: "function")).font(.caption)
        return Text("\(icon): \(value + unit)").textScale(.secondary)
    }
}

// MARK: Preview
// ============================================================================

#if DEBUG
    @Observable class TestMeasurement {
        var value: Double = 100
        var definition: UnitDefinition<UnitMass> = .init(
            UnitMass.grams,
            alts: [.kilograms, .pounds, .ounces],
            usage: .personWeight
        )
    }

    struct MeasurementFieldTest: View {
        @State var measurement = TestMeasurement()
        var body: some View {
            MeasurementField(
                .init(
                    self.$measurement.value,
                    definition: self.measurement.definition,
                ),
                title: "Measurement",
                image: Image(systemName: "flame"), color: .red,
                computed: 150, fractions: 0,
                validator: { $0 < 0 ? 0 : $0 }
            )
        }
    }
#endif

#Preview {
    Form {
        MeasurementFieldTest()
    }
}
