// import SwiftData
import SwiftUI

// REVIEW: animations
// FIXME: Picker not usable when disabled for non-local records

struct MeasurementField<Unit: Dimension>: View {
    @Environment(\.isEnabled) var isEnabled: Bool
    @LocalizedMeasurement var measurement: Measurement<Unit>

    let validator: ((Double) -> Bool)?
    let format: FloatingPointFormatStyle<Double>
    let showPicker: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            TextField("Not Set", value: $measurement.value, format: format)
                #if os(iOS)
                    .keyboardType(.decimalPad)
                #endif
                .multilineTextAlignment(.trailing)
                .foregroundStyle(isEnabled ? .primary : .tertiary)
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
