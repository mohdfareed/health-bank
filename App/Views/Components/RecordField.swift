import SwiftUI

struct RecordField<Unit: Dimension, DetailContent: View>: View {
    let definition: RecordFieldDefinition<Unit>
    @LocalizedMeasurement var measurement: Measurement<Unit>

    let isInternal: Bool
    let showPicker: Bool
    let computed: (() -> Double?)?

    @ViewBuilder let details: () -> DetailContent

    init(
        _ definition: RecordFieldDefinition<Unit>,
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
                subtitle.textScale(.secondary)
            } details: {
                details().textScale(.secondary)
            }
        }
        .disabled(!isInternal)
        .animation(.default, value: computed?())
    }

    @ViewBuilder
    private var subtitle: some View {
        if let computed = computed?(),
            abs(($measurement.baseValue ?? 0) - computed) > .ulpOfOne
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
        Text(measurement.unit.symbol)
    }
}

// MARK: Convenience Initializers
// ============================================================================

extension RecordField where DetailContent == EmptyView {
    init(
        _ definition: RecordFieldDefinition<Unit>,
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
