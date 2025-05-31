import SwiftUI

// MARK: Record Field Component
// ============================================================================

struct RecordField<Unit: Dimension, DetailContent: View>: View {
    let definition: RecordViewDefinition<Unit>
    @LocalizedMeasurement var measurement: Measurement<Unit>
    let source: DataSource
    let showPicker: Bool
    let computed: (() -> Double?)?
    @ViewBuilder let details: () -> DetailContent

    init(
        _ definition: RecordViewDefinition<Unit>,
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
        DetailedRow(image: definition.image, tint: definition.tint) {
            Text(String(localized: definition.title))
        } subtitle: {
            subtitle.textScale(.secondary)
        } details: {
            details().textScale(.secondary)
        } content: {
            MeasurementField(
                measurement: $measurement, validator: definition.validator,
                format: definition.formatter, editable: source == .local,
                showPicker: showPicker
            )
        }
        .animation(.default, value: measurement)
        .animation(.default, value: showPicker)
    }

    var subtitle: some View {
        HStack {
            if let computed = computed?(),
                computed != $measurement.value.wrappedValue,
                definition.validator?(computed) ?? true
            {
                Button {
                    withAnimation(.spring) {
                        $measurement.value.wrappedValue = computed
                    }
                } label: {
                    $measurement.computedText(
                        computed, format: definition.formatter
                    )
                }.contentTransition(.numericText())
            }
            Text(measurement.unit.symbol)
        }
    }
}

// MARK: Convenience Initializers
// ============================================================================

extension RecordField where DetailContent == EmptyView {
    init(
        _ definition: RecordViewDefinition<Unit>,
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
