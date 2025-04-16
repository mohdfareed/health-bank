import Foundation
import SwiftUI

let weightUnit = UnitDefinition<UnitMass>(usage: .personWeight)

struct PreviewUnit: View {
    @AppLocale var locale: Locale
    @LocalizedUnit var weight: Measurement<UnitMass>

    init(_ binding: Binding<Double>) {
        self._weight = LocalizedUnit(binding, definition: weightUnit)
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(
                    // "\(Measurement(value: 1.5, unit: UnitDuration.days).formatted(.measurement(width: .wide, usage: .asProvided)))"
                    "\(CalorieConsumed.macrosUnit.format(self.weight.value, for: self.locale))"
                ) {
                    print("Hello World!")
                }
                Spacer()
            }

            VStack {
                HStack {
                    Text("Weight Unit").font(.headline)
                    Spacer()
                    Text("\(self.$weight.formatted(.measurement(width: .wide)))")
                        .fontDesign(.monospaced)
                        .foregroundStyle(.secondary)
                }
                Divider()

                let units: [UnitMass] = [
                    UnitMass.grams, UnitMass.kilograms,
                    UnitMass.ounces, UnitMass.pounds,
                ]
                Picker("Locale", selection: self.$locale.$unitSystem) {
                    ForEach(Locale.MeasurementSystem.measurementSystems, id: \.identifier) {
                        locale in
                        Text(locale.rawValue).tag(locale)
                    }
                }
                Picker("Unit", selection: self.$weight.measurement.unit) {
                    ForEach(units, id: \.self) { unit in
                        Text(unit.symbol).tag(unit)
                    }
                }
            }
            .padding()
            .background(.background.secondary)
            .cornerRadius(25)

            VStack {
                HStack {
                    Text("Weight")
                    Spacer()
                    Text(
                        "\(self.$weight.formatted())"
                    )
                }
                Divider()
                HStack {
                    Text("Base Unit")
                    Spacer()
                    Text(
                        "\(self.$weight.formatted(as: .baseUnit()))"
                    )
                }
                Divider()
                HStack {
                    Text("Pounds")
                    Spacer()
                    Text(
                        "\(self.$weight.formatted(as: .pounds))"
                    )
                }
                Divider()
                HStack {
                    Text("Metric Tons")
                    Spacer()
                    Text(
                        "\(self.$weight.formatted(as: .metricTons))"
                    )
                }
                Divider()
                HStack {
                    Text("MilliGrams")
                    Spacer()
                    Text(
                        "\(self.$weight.formatted(as: .milligrams))"
                    )
                }
            }
            .padding()
            .background(.background.secondary)
            .cornerRadius(25)

            HStack {
                Text("Weight")
                Spacer()
                TextField(
                    "\(self.weight.formatted())",
                    value: $weight.measurement.value,
                    format: .number.precision(.fractionLength(2))
                )
                .textFieldStyle(.automatic)
                .multilineTextAlignment(.trailing)
                Text("\(self.$weight.unit.symbol)")
            }
            .padding()
        }
        .animation(.default, value: self.locale)
        .animation(.default, value: self.weight)
    }
}

// MARK: Preview
// ============================================================================

#if DEBUG
    struct PreviewUnitView: View {
        @State var weightValue: Double = 0.0

        var body: some View {
            PreviewUnit(self.$weightValue)
                .padding()
                .background(.background.secondary)
                .cornerRadius(25)
                .padding()
        }
    }
#endif

#Preview {
    PreviewUnitView()
        .preferredColorScheme(.dark)
}
