// import SwiftData
import SwiftUI

// REVIEW: animations

struct MeasurementField<Unit: Dimension>: View {
    @LocalizedMeasurement var measurement: Measurement<Unit>

    let validator: ((Double) -> Bool)?
    let format: FloatingPointFormatStyle<Double>
    let editable: Bool
    let showPicker: Bool

    var body: some View {
        HStack(alignment: .center) {
            if editable {
                TextField("Value", value: $measurement.value, format: format)
                    .multilineTextAlignment(.trailing)
                    .contentTransition(.numericText())
                    .onChange(of: $measurement.baseValue) {
                        if !isValid {
                            $measurement.baseValue = nil
                        }
                    }
            } else {
                Text($measurement.value.wrappedValue?.formatted(format) ?? "—")
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
            }

            if showPicker && $measurement.availableUnits().count > 1 {
                picker.frame(minWidth: 8, maxWidth: 8).fixedSize()
            }
        }
        .animation(.default, value: measurement)
        .animation(.default, value: editable)
        .animation(.default, value: showPicker)
        .animation(.default, value: isValid)
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
