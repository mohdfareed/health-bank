import Foundation
import SwiftUI

let weightUnit = UnitDefinition<UnitMass>(usage: .personWeight)

struct PreviewUnit: View {
    @Environment(\.unitsService) var unitsService
    @AppLocale var locale: Locale
    @LocalizedUnit var weight: Measurement<UnitMass>
    @State var selectedUnit: UnitMass = .grams

    init(_ binding: Binding<Double>) {
        self._weight = LocalizedUnit(binding, definition: weightUnit)
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(
                    "\(self.unitsService.format(1_200_000, for: self.locale, style: .units(allowed: [.weeks], width: .abbreviated)))"
                ) {
                    print(UnitDuration.seconds.symbol)
                }
                Spacer()
            }

            VStack {
                HStack {
                    Text("Weight").font(.headline)
                    Spacer()
                    Text(
                        "\(self.$weight.formatted(.measurement(width: .wide)))"
                    )
                    .fontDesign(.monospaced)
                    .foregroundStyle(.secondary)
                }
                Divider()

                Picker("Locale", selection: self.$locale.$unitSystem) {
                    ForEach(Locale.MeasurementSystem.measurementSystems, id: \.identifier) {
                        locale in
                        Text(locale.rawValue).tag(locale)
                    }
                }
                let units: [UnitMass] = [
                    UnitMass.grams, UnitMass.kilograms,
                    UnitMass.ounces, UnitMass.pounds,
                ]
                Picker("Unit", selection: self.$weight.unit) {
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
                    Text("Localized")
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
                    value: $weight.value,
                    format: .number.precision(.fractionLength(2))
                )
                .textFieldStyle(.automatic)
                .multilineTextAlignment(.trailing)
                Text("\(self.$weight.unit.wrappedValue.symbol)")
            }
            .padding()
        }
        // .animation(.default, value: self.locale)
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
