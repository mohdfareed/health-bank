import SwiftUI

// MARK: ViewModel
// ============================================================================

struct MeasurementFieldVM {
    let computed: Double?
    let (title, prompt): (String, String)
    let (image, color): (Image?, Color)
    let fractions: Int  // the number of digits

    init(
        title: String, prompt: String = "Value",
        image: Image? = nil, color: Color = .primary,
        computed: Double? = nil, fractions: Int = 0,
    ) {
        self.computed = computed
        self.title = title
        self.image = image
        self.color = color
        self.fractions = fractions
    }
}

// MARK: View
// ============================================================================

struct MeasurementField<D: Dimension>: View {
    @LocalizedMeasurement
    private var measurement: Measurement<D>
    private let vm: MeasurementFieldVM

    @State private var selectedUnit: D?
    @State private var inputValue: Double?

    init(_ measurement: LocalizedMeasurement<D>, vm: MeasurementFieldVM) {
        self._measurement = measurement
        self.vm = vm
    }

    var body: some View {
        DataRow(
            title: Text(self.vm.title), subtitle: computedText(),
            image: self.vm.image, color: self.vm.color
        ) {
            self.valueField()
            if self.$measurement.definition.alts.count > 1 {
                self.unitPicker() // only if there are multiple units
            } else {
                Spacer().frame(minWidth: 16, maxWidth: 16)
            }
        }
    }
}

// MARK: Components
// ============================================================================

extension MeasurementField {
    private func valueField() -> some View {
        TextField(
            value: self.$inputValue,
            format: .number.precision(.fractionLength(self.vm.fractions)),
            prompt: Text(self.vm.prompt)
        ) {}
        .multilineTextAlignment(.trailing)

        .onChange( // update the measurement value
            of: self.inputValue,
            {
                guard let value = self.inputValue else { return }
                self.$measurement.update(value, unit: self.selectedUnit)
            }
        )
    }

    private func unitPicker() -> some View {
        Picker("", selection: self.$selectedUnit) {
            ForEach(self.$measurement.definition.alts, id: \.self) { u in
                let meas = self.measurement.converted(to: u)
                let format = Measurement<D>.FormatStyle(
                    width: .wide,
                    numberFormatStyle: .number.precision(
                        .fractionLength(self.vm.fractions)
                    )
                )
                let style = self.$measurement.style(u, base: format)
                Text(meas.formatted(style).localizedCapitalized).tag(u)
            }

            if let computed = self.vm.computed {
                if computed != self.$measurement.baseValue {
                    Image(systemName: "arrow.clockwise").tag(nil as Dimension?)
                }
            }
        }.labelsHidden().frame(minWidth: 16, maxWidth: 16)
            .onChange(
                of: self.selectedUnit,
                {
                    guard let computed = self.vm.computed else { return }
                    if self.selectedUnit == nil {
                        self.resetValue(computed)
                    }
                }
            )
    }

    private func computedText() -> Text {
        let unit = (self.selectedUnit ?? self.measurement.unit).symbol
        guard let computed = self.vm.computed else {
            return Text(unit).textScale(.secondary)
        }
        guard computed != self.rawValue else {
            return Text(unit).textScale(.secondary)
        }

        let measurement = Measurement(
            value: computed, unit: self.$measurement.definition.baseUnit
        ).converted(to: self.$measurement.unit.wrappedValue)
        let value = measurement.value.formatted(
            .number.precision(.fractionLength(self.vm.fractions))
        )

        let icon = Text(Image(systemName: "function")).font(.caption)
        return Text("\(icon): \(value + unit)").textScale(.secondary)
    }

    private func resetValue(_ value: Double) {
        self.$measurement.update(value, self.$measurement.)
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
                LocalizedMeasurement(
                    self.$measurement.value,
                    definition: self.measurement.definition,
                ),
                vm: MeasurementFieldVM(
                    title: "Measurement",
                    image: Image(systemName: "flame"), color: .red,
                    computed: 1500, fractions: 0,
                    validator: { $0 < 0 ? 0 : $0 }
                )
            )

            MeasurementField(
                LocalizedMeasurement(
                    self.$measurement.value,
                    definition: self.measurement.definition,
                ),
                vm: MeasurementFieldVM(
                    title: "Measurement",
                    image: Image(systemName: "flame"), color: .accentColor,
                    fractions: 2,
                    validator: { $0 < 0 ? 0 : $0 }
                )
            )
        }
    }

    #Preview {
        Form { MeasurementFieldTest() }
    }
#endif
