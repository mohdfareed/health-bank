import SwiftUI

// REVIEW: animations

struct DateView: View {
    let date: Date?
    var body: some View {
        if let relativeDate = relativeDate {
            Text("\(Image.dateIcon) \(relativeDate)")
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
        ).converted(to: self.unit.wrappedValue)

        let text = measurement.value.formatted(format)
        let icon = Text(Image.computedIcon)
            .foregroundStyle(.indigo.secondary)
            .font(.footnote.bold())

        return Text("\(icon): \(text)")
    }
}
