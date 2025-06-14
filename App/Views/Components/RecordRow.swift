import SwiftUI

struct RecordRow<Field: FieldDefinition, DetailContent: View>: View {
    let field: Field
    @LocalizedMeasurement var measurement: Measurement<Field.Unit>

    let isInternal: Bool
    let showPicker: Bool
    let computed: (() -> Double?)?

    @FocusState
    private var isActive: Bool
    @ViewBuilder let details: () -> DetailContent

    init(
        field: Field,
        value: Binding<Double?>,
        isInternal: Bool,
        showPicker: Bool = false,
        @ViewBuilder details: @escaping () -> DetailContent = { EmptyView() }
    ) {
        self.field = field
        self._measurement = field.measurement(value)
        self.isInternal = isInternal
        self.showPicker = showPicker

        // Extract computed function from ComputedField if available
        self.computed = (field as? ComputedField)?.compute
        self.details = details
    }

    var body: some View {
        MeasurementField(
            validator: field.validator, format: field.formatter,
            showPicker: showPicker, measurement: $measurement,
        ) {
            DetailedRow(image: field.icon, tint: field.tint) {
                Text(String(localized: field.title))
            } subtitle: {
                computedButton.textScale(.secondary)
                Text(measurement.unit.symbol).textScale(.secondary)
            } details: {
                details().textScale(.secondary)
            }
        }
        .disabled(!isInternal)
        .focused($isActive)
        .animation(.default, value: computed?())

        .toolbar(
            content: {
                ToolbarItemGroup(placement: .keyboard) {
                    if isActive {
                        computedButton
                            .fixedSize()
                            .animation(.default, value: $measurement.baseValue)
                        Spacer()
                    }
                }
            }
        )
    }

    @ViewBuilder
    private var computedButton: some View {
        if let computed = computed?(), let baseValue = $measurement.baseValue,
            abs(baseValue - computed) > .ulpOfOne
        {
            HStack(alignment: .center, spacing: 2) {
                let icon = Image(systemName: "function").asText
                Text("\(icon):").foregroundStyle(.indigo.secondary)

                $measurement.computedText(
                    computed, format: field.formatter
                )
                .foregroundStyle(.indigo)
                .contentTransition(.numericText(value: computed))
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    withAnimation { $measurement.baseValue = computed }
                }
            )
        }
    }
}

// MARK: Convenience Initializers
// ============================================================================

extension RecordRow where DetailContent == EmptyView {
    init(
        field: Field,
        value: Binding<Double?>,
        isInternal: Bool,
        showPicker: Bool = false,
    ) {
        self.init(
            field: field,
            value: value,
            isInternal: isInternal,
            showPicker: showPicker,
            details: { EmptyView() }
        )
    }
}

// MARK: Extensions
// ============================================================================

extension LocalizedMeasurement {
    func computedText(
        _ computed: Double, format: FloatingPointFormatStyle<Double>
    ) -> some View {
        let measurement = Measurement(
            value: computed, unit: self.definition.baseUnit
        ).converted(to: self.unit.wrappedValue ?? self.definition.baseUnit)

        let value = measurement.value.formatted(format)
        return Text(value)
    }
}
