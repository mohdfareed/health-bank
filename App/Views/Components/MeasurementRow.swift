import SwiftUI

// REVIEW: animations

struct MeasurementRow<Unit: Dimension, DetailContent: View>: View {
    @LocalizedMeasurement var measurement: Measurement<Unit>
    let title: String.LocalizationValue
    let image: Image?
    let tint: Color?

    let source: DataSource
    let format: FloatingPointFormatStyle<Double>
    let showPicker: Bool

    let computed: (() -> Double?)?
    let validator: ((Double) -> Bool)?
    @ViewBuilder let details: () -> DetailContent

    var body: some View {
        DetailedRow(image: image, tint: tint) {
            Text(String(localized: title))
        } subtitle: {
            subtitle.textScale(.secondary)
        } details: {
            details().textScale(.secondary)
        } content: {
            MeasurementField(
                measurement: $measurement, validator: validator,
                format: format, editable: source == .local,
                showPicker: showPicker
            )
        }
        .animation(.default, value: measurement)
        .animation(.default, value: showPicker)
    }

    var subtitle: some View {
        HStack {
            sourcePrefix(source)
            if let computed = computed?(),
                computed != $measurement.value.wrappedValue,
                validator?(computed) ?? true
            {
                Button {
                    withAnimation(.spring) {
                        $measurement.value.wrappedValue = computed
                    }
                } label: {
                    $measurement.computedText(computed, format: format)
                }.contentTransition(.numericText())
            }
            Text(measurement.unit.symbol)
        }
    }

    private func sourcePrefix(_ source: DataSource) -> some View {
        if let icon = source.icon {
            Text(icon).font(.caption2).foregroundStyle(source.color)
        } else {
            Text("•")
        }
    }
}

struct UnitView<Unit: Dimension>: View {
    @LocalizedMeasurement var measurement: Measurement<Unit>
    let format: FloatingPointFormatStyle<Double>
    let computed: (() -> Double?)?
    let validator: ((Double) -> Bool)?

    var body: some View {
        HStack {
            if let computed = computed?(),
                computed != $measurement.value.wrappedValue,
                validator?(computed) ?? true
            {
                Button {
                    withAnimation(.spring) {
                        $measurement.value.wrappedValue = computed
                    }
                } label: {
                    $measurement.computedText(computed, format: format)
                }.contentTransition(.numericText())
            }
            Text(measurement.unit.symbol)
        }
    }
}
