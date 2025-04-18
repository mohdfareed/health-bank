import SwiftUI

struct MeasurementField<D: Dimension>: View {
    let text: String
    let image: String?
    let fractions: Int  // the number of fraction digits
    let validator: (Double?) -> Text? = { _ in nil }

    @LocalizedMeasurement var measurement: Measurement<D>

    var body: some View {
        HStack {
            TextField(
                value: self.$measurement.value,
                format: .number.precision(.fractionLength(self.fractions)),
                // prompt: self.validator(self.measurement.value)
            ) {
                if let image = self.image {
                    Label(self.text, systemImage: image)
                } else {
                    Label(self.text, systemImage: "").labelStyle(.titleOnly)
                }
            }
            .multilineTextAlignment(.trailing)

            Picker("", selection: self.$measurement.unit) {
                ForEach(self.$measurement.definition.alts, id: \.self) { u in
                    Text(
                        "TEST"
                        // Measurement(value: 1, unit: u)
                        //     .formatted(
                        //         self.$measurement.style(
                        //             base: .measurement(
                        //                 width: .abbreviated,
                        //                 numberFormatStyle: .number.precision(
                        //                     .fractionLength(self.fractions)
                        //                 )
                        //             )
                        //         )
                        //     )
                    )
                    .tag(u)
                }
            }
            // .pickerStyle(MenuPickerStyle())
            // .labelsHidden()
            .frame(minWidth: 16)
        }
    }
}
