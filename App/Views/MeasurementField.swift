import SwiftUI

// MARK: ViewModel
// ============================================================================

struct MeasurementFieldVM<D: Dimension> { // Made generic to align with MeasurementField
    let computed: Double?
    let (title, prompt): (String, String)
    let (image, color): (Image?, Color)
    let fractions: Int
    let validator: ((Double) -> String?)? // Validator returns an error message or nil

    init(
        title: String, prompt: String = "Enter value", // Default prompt
        image: Image? = nil, color: Color = .primary,
        computed: Double? = nil, fractions: Int = 0,
        validator: ((Double) -> String?)? = nil
    ) {
        self.computed = computed
        self.title = title
        self.prompt = prompt
        self.image = image
        self.color = color
        self.fractions = fractions
        self.validator = validator
    }
}

// MARK: View
// ============================================================================

struct MeasurementField<D: Dimension>: View {
    @LocalizedMeasurement var measurement: Measurement<D>
    private let vm: MeasurementFieldVM<D>

    @State private var inputValue: Double?
    @State private var validationError: String?
    // selectedUnit is now directly from LocalizedMeasurement's overrideUnit binding
    // @State private var selectedUnit: D? // No longer needed here

    // Initializer to ensure LocalizedMeasurement is correctly set up
    init(
        baseValue: Binding<Double>,
        definition: UnitDefinition<D>,
        overrideUnit: Binding<D?>, // Pass binding for overrideUnit
        vm: MeasurementFieldVM<D>
    ) {
        self._measurement = LocalizedMeasurement(
            baseValue: baseValue,
            definition: definition,
            overrideUnit: overrideUnit // Use the passed binding
        )
        self.vm = vm
        // Initialize inputValue based on the initial measurement value
        // This needs to be done carefully, possibly in .onAppear or via an initial value for inputValue
        // For now, let's set it directly, assuming measurement is ready.
        // This will be refined if issues arise with initialization timing.
        self._inputValue = State(initialValue: self._measurement.wrappedValue.wrappedValue.value)
    }


    var body: some View {
        DataRow(
            title: Text(self.vm.title),
            subtitle: computedValueText(),
            caption: validationErrorText(),
            image: self.vm.image,
            color: self.vm.color
        ) {
            HStack { // HStack for TextField and Picker
                valueField()
                if !measurement.availableUnits().isEmpty && measurement.availableUnits().count > 1 {
                    unitPicker()
                }
            }
        }
        .onAppear { // Initialize inputValue when the view appears
            self.inputValue = measurement.wrappedValue.value
            // Also ensure selectedUnit reflects the initial state of measurement.overrideUnit
            // This is implicitly handled as selectedUnit now directly uses measurement.overrideUnit
        }
    }
}

// MARK: Components
// ============================================================================

extension MeasurementField {
    private func valueField() -> some View {
        TextField(
            vm.prompt,
            value: $inputValue,
            format: .number.precision(.fractionLength(vm.fractions))
        )
        .multilineTextAlignment(.trailing)
        .foregroundStyle(validationError == nil ? .primary : .red)
        .onChange(of: inputValue) { oldValue, newValue in
            guard let val = newValue else {
                validationError = "Value cannot be empty" // Or handle as per preference
                return
            }

            if let validatorMessage = vm.validator?(val) {
                validationError = validatorMessage
                // Optionally, prevent measurement update or revert value:
                // self.inputValue = oldValue // Reverts to previous valid value
                // return // Prevents updating the measurement with an invalid value
            } else {
                validationError = nil
                measurement.update(val, unit: measurement.wrappedValue.unit)
            }
        }
    }

    private func unitPicker() -> some View {
        Picker("Unit", selection: $measurement.overrideUnit) { // Bind directly to measurement.overrideUnit
            ForEach(measurement.availableUnits(), id: \\.self) { unit in
                Text(unit.symbol).tag(unit as D?) // Ensure tag is D?
            }
            // Reset to computed functionality
            if vm.computed != nil {
                Divider()
                Label("Reset to Calculated", systemImage: "arrow.clockwise")
                    .tag(nil as D?) // Using nil tag to signify reset
            }
        }
        .labelsHidden()
        .frame(minWidth: 60, idealWidth: 70, maxWidth: 80) // Give picker a bit more space
        .onChange(of: measurement.overrideUnit) { oldValue, newValue in
            if newValue == nil && oldValue != nil { // Reset was chosen via the nil tag
                if let computedValue = vm.computed {
                    // Convert computed value (assumed to be in base unit) to the new display unit for inputValue
                    let computedMeasurementInBase = Measurement(value: computedValue, unit: measurement.definition.baseUnit)
                    // If overrideUnit becomes nil, effectiveUnit in LocalizedMeasurement will be locale-based
                    let targetUnitForDisplay = measurement.definition.unit(for: measurement.locale)
                    let computedInTargetUnit = computedMeasurementInBase.converted(to: targetUnitForDisplay)

                    measurement.baseValue = computedValue // Update base value
                    inputValue = computedInTargetUnit.value // Update displayed input
                    measurement.overrideUnit = targetUnitForDisplay // Explicitly set override to keep consistency
                }
            } else if let newUnit = newValue {
                 // When unit changes, update inputValue to reflect the measurement in the new unit
                inputValue = measurement.wrappedValue.converted(to: newUnit).value
            }
            validationError = nil // Clear validation error on unit change
        }
    }

    private func computedValueText() -> Text? {
        guard let computedValue = vm.computed else { return nil }

        // Display computed value in the current effective unit of the measurement
        let effectiveUnit = measurement.wrappedValue.unit
        let computedInEffectiveUnit = Measurement(value: computedValue, unit: measurement.definition.baseUnit)
            .converted(to: effectiveUnit)

        let formattedValue = computedInEffectiveUnit.value.formatted(
            .number.precision(.fractionLength(vm.fractions))
        )
        return Text(Image(systemName: "function")) + Text(" Est: \\(formattedValue) \\(effectiveUnit.symbol)")
    }

    private func validationErrorText() -> Text? {
        guard let error = validationError else { return nil }
        return Text(error).foregroundStyle(.red)
    }
}

// MARK: Preview
// ============================================================================

#if DEBUG
@Observable
private class TestMeasurementData<D: Dimension> {
    var baseValue: Double
    var overrideUnit: D?
    let definition: UnitDefinition<D>
    let computedValue: Double?
    let validator: ((Double) -> String?)?

    init(baseValue: Double, overrideUnit: D? = nil, definition: UnitDefinition<D>, computedValue: Double? = nil, validator: ((Double) -> String?)? = nil) {
        self.baseValue = baseValue
        self.overrideUnit = overrideUnit
        self.definition = definition
        self.computedValue = computedValue
        self.validator = validator
    }
}

struct MeasurementFieldTestView: View {
    // Example for UnitMass
    @State private var massData = TestMeasurementData(
        baseValue: 70000, // grams (70kg)
        definition: .init(baseUnit: UnitMass.grams, altUnits: [UnitMass.kilograms, UnitMass.pounds], usage: .personWeight),
        computedValue: 72000, // 72kg in grams
        validator: { value in
            if value < 0 { return "Weight cannot be negative." }
            if value > 500000 { return "Weight seems too high."} // 500kg
            return nil
        }
    )

    // Example for UnitEnergy
    @State private var energyData = TestMeasurementData(
        baseValue: 2000 * 1000, // Cal (2000 kcal) stored in calories
        definition: .init(baseUnit: UnitEnergy.calories, altUnits: [UnitEnergy.kilocalories, UnitEnergy.joules], usage: .foodEnergy),
        computedValue: 2200 * 1000, // 2200 kcal in calories
        validator: { value in
            if value < 0 { return "Energy cannot be negative." }
            return nil
        }
    )

    // Example for UnitLength
    @State private var lengthData = TestMeasurementData(
        baseValue: 1.75, // meters
        definition: .init(baseUnit: UnitLength.meters, altUnits: [UnitLength.centimeters, UnitLength.feet, UnitLength.inches], usage: .personHeight),
        computedValue: 1.80, // 1.80 meters
        validator: { value in
            if value <= 0 { return "Height must be positive."}
            if value > 3 {return "Height seems too high (over 3m)."}
            return nil
        }
    )


    var body: some View {
        Form {
            Section("Body Weight (Mass)") {
                MeasurementField(
                    baseValue: $massData.baseValue,
                    definition: massData.definition,
                    overrideUnit: $massData.overrideUnit,
                    vm: MeasurementFieldVM(
                        title: "Weight",
                        image: Image(systemName: "figure.stand"), color: .blue,
                        computed: massData.computedValue,
                        fractions: 1, // 1 decimal place for kg/lbs
                        validator: massData.validator
                    )
                )
                Text("Base value: \\(massData.baseValue.formatted()) \\(massData.definition.baseUnit.symbol)")
                Text("Override unit: \\(massData.overrideUnit?.symbol ?? "None")")
            }

            Section("Dietary Energy") {
                MeasurementField(
                    baseValue: $energyData.baseValue,
                    definition: energyData.definition,
                    overrideUnit: $energyData.overrideUnit,
                    vm: MeasurementFieldVM(
                        title: "Calories",
                        image: Image(systemName: "flame.fill"), color: .orange,
                        computed: energyData.computedValue,
                        fractions: 0, // 0 decimal places for kcal
                        validator: energyData.validator
                    )
                )
                Text("Base value: \\(energyData.baseValue.formatted()) \\(energyData.definition.baseUnit.symbol)")
                 Text("Override unit: \\(energyData.overrideUnit?.symbol ?? "None")")
            }

            Section("Height (Length)") {
                MeasurementField(
                    baseValue: $lengthData.baseValue,
                    definition: lengthData.definition,
                    overrideUnit: $lengthData.overrideUnit,
                    vm: MeasurementFieldVM(
                        title: "Height",
                        image: Image(systemName: "ruler.fill"), color: .green,
                        computed: lengthData.computedValue,
                        fractions: 2, // 2 decimal places for meters/feet
                        validator: lengthData.validator
                    )
                )
                Text("Base value: \\(lengthData.baseValue.formatted()) \\(lengthData.definition.baseUnit.symbol)")
                Text("Override unit: \\(lengthData.overrideUnit?.symbol ?? "None")")
            }
        }
    }
}

#Preview {
    MeasurementFieldTestView()
}
#endif
