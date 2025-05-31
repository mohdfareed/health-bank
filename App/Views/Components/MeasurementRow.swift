import SwiftData
import SwiftUI

// TODO: Add value validation
// TODO: Add computed field validation

struct MeasurementField<Unit: Dimension>: View {
    @Environment(\.modelContext) private var context: ModelContext
    @LocalizedMeasurement var measurement: Measurement<Unit>
    let format: FloatingPointFormatStyle<Double>
    let editable: Bool
    let showPicker: Bool

    var body: some View {
        HStack(alignment: .center) {
            if editable {
                TextField("", value: $measurement.value, format: format)
                    .multilineTextAlignment(.trailing)
            } else {
                Text($measurement.value.wrappedValue?.formatted(format) ?? "")
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
            }

            if showPicker && $measurement.availableUnits().count > 1 {
                picker.frame(minWidth: 8, maxWidth: 8).fixedSize()
            }
        }
    }

    var picker: some View {
        Picker("", selection: $measurement.unit) {
            ForEach($measurement.availableUnits(), id: \.self) {
                Text(
                    measurement.converted(to: $0).formatted(
                        .measurement(
                            width: .wide, usage: .asProvided,
                            numberFormatStyle: format
                        )
                    ).localizedCapitalized
                ).tag($0)
            }

            Divider()
            Label {
                Text("Default")
            } icon: {
                Image.resetIcon
            }.tag(nil as Unit?)
        }.labelsHidden()
    }
}

struct MeasurementRow<Unit: Dimension>: View {
    @LocalizedMeasurement var measurement: Measurement<Unit>
    let title: String.LocalizationValue
    let image: Image?
    let tint: Color?

    let computed: (() -> Double?)?
    let date: Date?
    let source: DataSource?

    let format: FloatingPointFormatStyle<Double>
    let showPicker: Bool

    var body: some View {
        DetailedRow(image: image, tint: tint) {
            Text(String(localized: title))
        } subtitle: {
            subtitlePrefix.textScale(.secondary)
        } details: {
            detailsText.textScale(.secondary)
        } content: {
            HStack(spacing: 8) {
                MeasurementField(
                    measurement: $measurement,
                    format: format, editable: source == .local,
                    showPicker: showPicker
                )
            }
        }
    }

    var subtitlePrefix: some View {
        HStack {
            source == .local
                ? Text("•")
                : Text(Image.computedIcon)
                    .font(.caption2)
                    .foregroundColor(source?.color)

            let currentValue = $measurement.value.wrappedValue
            if let computed = computed?(), computed != currentValue {
                Button {
                    withAnimation(.spring) {
                        $measurement.value.wrappedValue = computed
                    }
                } label: {
                    $measurement.computedText(
                        computed, format: format
                    )
                }
            }

            Text(measurement.unit.symbol)
        }
    }

    var detailsText: Text? {
        guard let date = date else {
            return nil
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.dateTimeStyle = .numeric

        let relativeDate = formatter.localizedString(
            for: date, relativeTo: Date.now
        )
        return Text("\(Image.dateIcon) \(relativeDate)")
    }
}

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
        ).converted(to: self.unit.wrappedValue)

        let text = measurement.value.formatted(format)
        let icon = Text(Image.computedIcon)
            .foregroundStyle(.indigo.secondary)
            .font(.footnote.bold())

        return Text("\(icon): \(text)")
    }
}
