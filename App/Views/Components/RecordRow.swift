import SwiftUI

struct RecordRow<Unit: Dimension, DetailContent: View>: View {
    let definition: RecordRowDefinition<Unit>
    @LocalizedMeasurement var measurement: Measurement<Unit>

    let isInternal: Bool
    let showPicker: Bool
    let computed: (() -> Double?)?

    @FocusState
    private var isActive: Bool
    @ViewBuilder let details: () -> DetailContent

    init(
        _ definition: RecordRowDefinition<Unit>,
        value: Binding<Double?>,
        isInternal: Bool,
        showPicker: Bool = false,
        computed: (() -> Double?)? = nil,
        @ViewBuilder details: @escaping () -> DetailContent = { EmptyView() }
    ) {
        self.definition = definition
        self._measurement = definition.measurement(value)
        self.isInternal = isInternal
        self.showPicker = showPicker
        self.computed = computed
        self.details = details
    }

    var body: some View {
        MeasurementField(
            validator: definition.validator, format: definition.formatter,
            showPicker: showPicker, measurement: $measurement,
        ) {
            DetailedRow(image: definition.image, tint: definition.tint) {
                Text(String(localized: definition.title))
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
            HStack(spacing: 2) {
                let icon = Image(systemName: "function").asText
                Text("\(icon):").foregroundStyle(.indigo.secondary)

                $measurement.computedText(
                    computed, format: definition.formatter
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
        _ definition: RecordRowDefinition<Unit>,
        value: Binding<Double?>,
        isInternal: Bool,
        showPicker: Bool = false,
        computed: (() -> Double?)? = nil
    ) {
        self.init(
            definition,
            value: value,
            isInternal: isInternal,
            showPicker: showPicker,
            computed: computed,
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
