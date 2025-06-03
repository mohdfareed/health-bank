// import SwiftData
import SwiftUI

// REVIEW: animations

struct MeasurementField<Unit: Dimension>: View {
    @LocalizedMeasurement var measurement: Measurement<Unit>

    let validator: ((Double) -> Bool)?
    let format: FloatingPointFormatStyle<Double>
    let showPicker: Bool
    let disabled: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            TextField("—", value: $measurement.value, format: format)
                #if os(iOS)
                    .keyboardType(.decimalPad)
                #endif
                .multilineTextAlignment(.trailing)
                .foregroundStyle(!disabled ? .primary : .tertiary)
                .disabled(disabled)
                .onChange(of: $measurement.baseValue) {
                    if !isValid {
                        $measurement.baseValue = nil
                    }
                }
            if showPicker && $measurement.availableUnits().count > 1 {
                picker.frame(maxWidth: 12, maxHeight: 8).fixedSize()
            }
        }
        .animation(.default, value: $measurement.value.wrappedValue)
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
    }

    private var isValid: Bool {
        guard let value = $measurement.baseValue,
            let validator = validator
        else { return true }
        return validator(value)
    }
}
