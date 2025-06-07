import SwiftUI

struct RecordField<Unit: Dimension, DetailContent: View>: View {
    let definition: RecordFieldDefinition<Unit>
    @LocalizedMeasurement var measurement: Measurement<Unit>

    let source: DataSource
    let showPicker: Bool
    let computed: (() -> Double?)?

    @ViewBuilder let details: () -> DetailContent

    init(
        _ definition: RecordFieldDefinition<Unit>,
        value: Binding<Double?>,
        source: DataSource,
        showPicker: Bool = false,
        computed: (() -> Double?)? = nil,
        @ViewBuilder details: @escaping () -> DetailContent = { EmptyView() }
    ) {
        self.definition = definition
        self._measurement = definition.measurement(value)
        self.source = source
        self.showPicker = showPicker
        self.computed = computed
        self.details = details
    }

    var body: some View {
        MeasurementField(
            validator: definition.validator, format: definition.formatter,
            showPicker: showPicker, disabled: source != .local,
            measurement: $measurement,
        ) {
            DetailedRow(image: definition.image, tint: definition.tint) {
                Text(String(localized: definition.title))
            } subtitle: {
                subtitle.textScale(.secondary)
            } details: {
                details().textScale(.secondary)
            }
        }
    }

    @ViewBuilder
    private var subtitle: some View {
        if let computed = computed?(),
            computed != $measurement.value.wrappedValue,
            definition.validator?(computed) ?? true
        {
            Button {
                withAnimation(.default) {
                    $measurement.value.wrappedValue = computed
                }
            } label: {
                $measurement.computedText(
                    computed, format: definition.formatter
                )
            }
        }
        Text(measurement.unit.symbol).textScale(.secondary)
    }
}

// MARK: Convenience Initializers
// ============================================================================

extension RecordField where DetailContent == EmptyView {
    init(
        _ definition: RecordFieldDefinition<Unit>,
        value: Binding<Double?>,
        source: DataSource,
        showPicker: Bool = false,
        computed: (() -> Double?)? = nil
    ) {
        self.init(
            definition,
            value: value,
            source: source,
            showPicker: showPicker,
            computed: computed,
            details: { EmptyView() }
        )
    }
}
