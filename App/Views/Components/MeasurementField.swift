import SwiftUI

struct MeasurementField<Unit: Dimension, Content: View>: View {
    let validator: ((Double) -> Bool)?

    let format: FloatingPointFormatStyle<Double>
    let showPicker: Bool
    let disabled: Bool

    @LocalizedMeasurement
    var measurement: Measurement<Unit>
    @ViewBuilder
    var label: () -> Content

    @FocusState
    private var isActive: Bool

    var body: some View {
        LabeledContent {
            HStack(alignment: .center, spacing: 4) {
                TextField("—", value: $measurement.value, format: format)
                    .focused($isActive)

                    .multilineTextAlignment(.trailing)
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif

                    .disabled(disabled)
                    .foregroundStyle(!disabled ? .primary : .tertiary)

                if showPicker && $measurement.availableUnits().count > 1 {
                    picker.frame(maxWidth: 12, maxHeight: 8).fixedSize()
                }
            }.layoutPriority(-1)
        } label: {
            label().gesture(
                TapGesture().onEnded {
                    withAnimation(.default) {
                        isActive = true
                    }
                }, isEnabled: !isActive
            )
        }

        .onChange(of: $measurement.baseValue) {
            if !isValid {
                withAnimation(.default) {
                    $measurement.baseValue = nil
                }
            }
        }

        .animation(.default, value: $measurement.baseValue)
        .animation(.default, value: $measurement.displayUnit)
        .animation(.default, value: disabled)
    }

    private var picker: some View {
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

            Divider()
            Label {
                Text("Default")
            } icon: {
                Image(systemName: "arrow.clockwise")
            }.tag(nil as Unit?)
        }.labelsHidden()
            .animation(.default, value: $measurement.unit.wrappedValue)
    }

    private var isValid: Bool {
        guard let value = $measurement.baseValue,
            let validator = validator
        else { return true }
        return validator(value)
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
        ).converted(to: self.unit.wrappedValue ?? self.definition.baseUnit)

        let text = measurement.value.formatted(format)
        let icon = Image(systemName: "function").asText
        return Text("\(icon): \(text)").foregroundStyle(.indigo.secondary)
    }
}
