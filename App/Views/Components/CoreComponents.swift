import SwiftUI

// REVIEW: animations

struct ValueView<Unit: Dimension>: View {
    @LocalizedMeasurement var measurement: Measurement<Unit>
    let icon: Image?
    let tint: Color?
    let format: FloatingPointFormatStyle<Double>

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            icon?.asText.foregroundStyle(tint ?? .primary)
            Text(
                $measurement.formatted(width: .narrow, format: format)
            )
        }
    }
}

struct DateView: View {
    let date: Date?
    var body: some View {
        if let relativeDate = relativeDate {
            Text(relativeDate)
        }
    }

    var relativeDate: String? {
        guard let date = date else {
            return nil
        }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.dateTimeStyle = .numeric

        return formatter.localizedString(
            for: date, relativeTo: Date.now
        )
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
        ).converted(to: self.unit.wrappedValue ?? self.definition.baseUnit)

        let text = measurement.value.formatted(format)
        let icon = Image(systemName: "function").asText
        return Text("\(icon): \(text)").foregroundStyle(.indigo.secondary)
    }
}

extension LocalizedMeasurement {
    func formatted(
        width: Measurement<D>.FormatStyle.UnitWidth,
        format: FloatingPointFormatStyle<Double>
    ) -> String {
        wrappedValue.formatted(
            .measurement(
                width: width, usage: definition.usage,
                numberFormatStyle: format
            )
        )
    }
}
