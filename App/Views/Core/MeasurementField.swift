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
    @LocalizedMeasurement private var meas: Measurement<D>
    private var vm: MeasurementFieldVM
    private var editable: Bool = false

    init(
        _ meas: LocalizedMeasurement<D>, vm: MeasurementFieldVM,
        editable: Bool = false
    ) {
        self._meas = meas
        self.vm = vm
        self.editable = editable
    }

    var body: some View {
        let u = self.meas.unit.symbol

        DataRow(
            vm: .init(
                title: self.vm.title,
                subtitle: Text(u).textScale(.secondary),
                caption: computedText(),
                image: self.vm.image, color: self.vm.color
            )
        ) {
            HStack {
                if editable {
                    editableField()
                } else {
                    valueField()
                }

                if $meas.availableUnits().count > 1 {
                    self.unitPicker()  // only if there are multiple units
                } else {
                    Spacer().frame(minWidth: 16, maxWidth: 16)
                }
            }
        }

        .onChange(of: $meas.unit) { oldUnit, newUnit in
            // Reset to display unit
            guard newUnit == nil else { return }
            withAnimation(.default) {
                $meas.unit = oldUnit
            }

            // Reset to computed value
            guard let computed = self.vm.computed else { return }
            withAnimation(.default) {
                $meas.baseValue = computed
            }
        }
    }
}

// MARK: Components
// ============================================================================

extension MeasurementField {
    private func valueField() -> some View {
        Text(
            meas.value,
            format: .number.precision(.fractionLength(self.vm.fractions)),
        )
        .multilineTextAlignment(.trailing)
        .animation(.default, value: meas.unit)
    }

    private func editableField() -> some View {
        TextField(
            value: $meas.value,
            format: .number.precision(.fractionLength(self.vm.fractions)),
        ) {}
        .multilineTextAlignment(.trailing)
        .animation(.default, value: meas.unit)
    }

    private func unitPicker() -> some View {
        Picker(
            "", selection: $meas.$unit,
            content: {
                ForEach($meas.availableUnits(), id: \.self) { u in
                    let meas = meas.converted(to: u)
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
                if self.vm.computed != nil && vm.computed != $meas.baseValue {
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
        if self.vm.computed == $meas.baseValue {
            return nil
        }
        guard let computed = self.vm.computed else {
            return nil
        }

        let measurementValue = Measurement(
            value: computed, unit: $meas.definition.baseUnit
        ).converted(to: meas.unit)
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
        .modifier(CardStyle())
        .padding()
    }
}

#Preview {
    MeasurementField_Preview()
}
