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
    }

    @ViewBuilder
    private var subtitle: some View {
        if let computed = computed?(),
            let currentValue = $measurement.baseValue,
            abs(computed - currentValue) > 0.001,  // Use epsilon comparison for floating point
            definition.validator?(computed) ?? true
        {
            Button {
                withAnimation(.default) {
                    $measurement.baseValue = computed
                }
            } label: {
                HStack(spacing: 4) {
                    let icon = Image(systemName: "function").asText
                    Text("\(icon):").foregroundStyle(.indigo.secondary)
                    $measurement.computedText(
                        computed, format: definition.formatter
                    )
                    .contentTransition(.numericText())
                }
            }
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
        _ computed: Double?, format: FloatingPointFormatStyle<Double>
    ) -> Text? {
        guard let computed = computed else {
            return nil
        }

        guard computed != self.baseValue else {
            return nil
        }

        let measurement = Measurement(
            value: computed, unit: self.definition.baseUnit
        ).converted(to: self.unit.wrappedValue ?? self.definition.baseUnit)

        let text = measurement.value.formatted(format)
        return Text(text).foregroundStyle(.indigo.secondary)
    }
}
