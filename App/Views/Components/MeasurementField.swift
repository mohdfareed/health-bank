import SwiftData
import SwiftUI

// REVIEW: animations

// TODO: Add value validation
struct MeasurementField<Unit: Dimension>: View {
    @Environment(\.modelContext) private var context: ModelContext
    @LocalizedMeasurement var measurement: Measurement<Unit>

    let format: FloatingPointFormatStyle<Double>
    let editable: Bool
    let showPicker: Bool

    var body: some View {
        HStack(alignment: .center) {
            if editable {
                TextField("Value", value: $measurement.value, format: format)
                    .multilineTextAlignment(.trailing)
                    .contentTransition(.numericText())
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

            Divider()
            Label {
                Text("Default")
            } icon: {
                Image.resetIcon
            }.tag(nil as Unit?)
        }.labelsHidden()
    }
}
