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
        .disabled(source != .local)
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
