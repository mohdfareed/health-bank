import SwiftUI

// MARK: ViewModel
// ============================================================================

@Observable class MeasurementFieldVM {
    let computed: Double?
    let title: Text
    let (image, color): (Image?, Color)
    let fractions: Int  // the number of digits

    init(
        title: Text, image: Image? = nil, color: Color = .primary,
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
    @LocalizedMeasurement private var measurement: Measurement<D>
    private var vm: MeasurementFieldVM

    init(_ measurement: LocalizedMeasurement<D>, vm: MeasurementFieldVM) {
        self._measurement = measurement
        self.vm = vm
    }

    var body: some View {
        let u = self.measurement.unit.symbol

        DataRow(
            vm: .init(
                title: self.vm.title,
                subtitle: Text(u).textScale(.secondary),
                caption: computedText(),
                image: self.vm.image, color: self.vm.color
            )
        ) {
            HStack {
                self.valueField()
                if $measurement.availableUnits().count > 1 {
                    self.unitPicker()  // only if there are multiple units
                } else {
                    Spacer().frame(minWidth: 16, maxWidth: 16)
                }
            }
        }

        .onChange(of: $measurement.unit) { oldUnit, newUnit in
            // Reset to display unit
            guard newUnit == nil else { return }
            withAnimation(.default) {
                $measurement.unit = oldUnit
            }

            // Reset to computed value
            guard let computed = self.vm.computed else { return }
            withAnimation(.default) {
                $measurement.baseValue = computed
            }
        }
    }
}

// MARK: Components
// ============================================================================

extension MeasurementField {
    private func valueField() -> some View {
        TextField(
            value: $measurement.value,
            format: .number.precision(.fractionLength(self.vm.fractions)),
        ) {}
        .multilineTextAlignment(.trailing)
        .animation(.default, value: measurement.unit)
    }

    private func unitPicker() -> some View {
        Picker(
            "", selection: $measurement.$unit,
            content: {
                ForEach($measurement.availableUnits(), id: \.self) { u in
                    let meas = measurement.converted(to: u)
                    let style = Measurement<D>.FormatStyle(
                        width: .wide,
                        usage: .asProvided,
                        numberFormatStyle: .number.precision(
                            .fractionLength(
                                vm.fractions
                            )),
                    )
                    let formatted = meas.formatted(style).localizedCapitalized
                    Text(formatted).tag(u)
                }

                // Reset option
                if vm.computed != $measurement.baseValue {
                    Divider()
                    Label(
                        String(localized: "Estimate"),
                        systemImage: "function"
                    ).foregroundStyle(Color.accent).tag(nil as D?)
                }
            }
        ) {}
        .labelsHidden().frame(minWidth: 16, maxWidth: 16)
    }

    private func computedText() -> Text? {
        if self.vm.computed == $measurement.baseValue {
            return nil
        }
        guard let computed = self.vm.computed else {
            return nil
        }

        let measurementValue = Measurement(
            value: computed, unit: $measurement.definition.baseUnit
        ).converted(to: measurement.unit)
        let value = measurementValue.value.formatted(
            .number.precision(.fractionLength(self.vm.fractions))
        )

        let icon = Text(Image(systemName: "function")).font(.caption)
        return Text("\(icon): \(value)").textScale(.secondary)
    }
}

// MARK: Preview
// ============================================================================

struct MeasurementField_Preview: View {
    @State private var baseValue: Double = 100
    @State private var overrideUnit: UnitLength? = nil

    var body: some View {
        VStack {
            MeasurementField(
                LocalizedMeasurement(
                    baseValue: $baseValue,
                    definition: UnitDefinition<UnitLength>(
                        .meters,
                        alts: [.kilometers, .feet, .yards],
                        usage: .asProvided
                    )
                ),
                vm: MeasurementFieldVM(
                    title: Text("Distance"),
                    image: Image(systemName: "ruler"),
                    color: .blue,
                    computed: 75.0,
                    fractions: 2
                )
            )
        }
        .padding()
    }
}

#Preview {
    MeasurementField_Preview()
}
