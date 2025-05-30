import SwiftData
import SwiftUI

// TODO: Add animations.

struct DetailedRow<Content: View>: View {
    let title: Text
    let subtitle: Text?
    let details: Text?
    let image: Image?
    let tint: Color?

    @ViewBuilder var content: () -> Content

    var body: some View {
        Label {
            HStack(spacing: 8) {
                VStack(alignment: .leading) {
                    HStack {
                        title
                        if let subtitle = subtitle {
                            subtitle.textScale(.secondary)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let details = details {
                        details.textScale(.secondary)
                            .foregroundStyle(.secondary)
                    }
                }
                .truncationMode(.tail)
                .lineLimit(1)

                Spacer()
                content().fixedSize()
            }
        } icon: {
            if let image = image {
                image.foregroundStyle(tint ?? .primary)
            }
        }
    }
}

// TODO: Add value validation.
// TODO: Support null to allow clearing nullable values.

struct MeasurementField<Unit: Dimension>: View {
    @Environment(\.modelContext) private var context: ModelContext
    @LocalizedMeasurement var measurement: Measurement<Unit>
    let format: FloatingPointFormatStyle<Double>
    let editable: Bool

    var measFormat: Measurement<Unit>.FormatStyle {
        .measurement(
            width: .wide, usage: .asProvided,
            numberFormatStyle: format
        )
    }

    var body: some View {
        HStack(alignment: .center) {
            if editable {
                TextField("", value: $measurement.value, format: format)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: measurement.value) {
                        if (try? context.save()) == nil {
                            AppLogger.new(for: MeasurementField.self)
                                .error("Failed to save measurement.")
                        }
                    }
            } else {
                Text(
                    $measurement.value.wrappedValue?.formatted(format) ?? ""
                ).multilineTextAlignment(.trailing)
            }

            if $measurement.availableUnits().count > 1 {
                picker.frame(minWidth: 8, maxWidth: 8).fixedSize()
            } else {
                Spacer().frame(minWidth: 8, maxWidth: 8).fixedSize()
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
        }
        .labelsHidden()
    }
}

// FIXME: Computed field is not reactive
// TODO: Add computed field validation.

struct MeasurementRow<Unit: Dimension>: View {
    @LocalizedMeasurement var measurement: Measurement<Unit>
    let title: String.LocalizationValue
    let image: Image?
    let tint: Color?

    var computed: Double?
    let date: Date?
    let source: DataSource?
    let format: FloatingPointFormatStyle<Double>

    var body: some View {
        DetailedRow(
            title: Text(String(localized: title)),
            subtitle: subtitlePrefix?.textScale(.secondary),
            details: detailsText?.textScale(.secondary),
            image: image, tint: tint
        ) {
            MeasurementField(
                measurement: $measurement,
                format: format, editable: source == .local
            )
        }
    }

    var subtitlePrefix: Text? {
        let unit = measurement.unit.symbol
        let computed =
            $measurement.computedText(
                computed, format: format
            ) ?? Text("")

        if let source = source, let icon = source.icon {
            let icon = Text(icon).font(.caption2)
                .foregroundColor(source.color)
            return Text("\(icon)  \(computed)\(unit)")
        } else {
            return Text("•  \(computed)\(unit)")
        }
    }

    var detailsText: Text? {
        if let date = date {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.dateTimeStyle = .numeric
            let relativeDate = formatter.localizedString(
                for: date, relativeTo: Date.now
            )
            return Text(relativeDate)
        } else {
            return nil
        }
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
        let icon = Text(Image(systemName: "function"))
            .foregroundStyle(.indigo.secondary)
            .font(.footnote.bold())
        return Text("\(icon): \(text)")
    }
}

// MARK: Preview
// ============================================================================

struct MeasurementRow_Previews: View {
    @Query.Singleton() private var budgets: Budgets
    @State private var weight = Weight(70.0)
    @State private var toggle = false

    var body: some View {
        MeasurementRow(
            measurement: .init(
                $budgets.calories,
                definition: .init(.kilocalories, usage: .food)
            ),
            title: "Calories", image: Image.calories, tint: .orange,
            computed: 2000, date: budgets.date, source: nil,
            format: .number.precision(.fractionLength(0)),
        )

        MeasurementRow(
            measurement: weight.measurement,
            title: "Weight", image: Image.weight, tint: .purple,
            computed: nil, date: budgets.date, source: nil,
            format: .number.precision(.fractionLength(2)),
        )

        DetailedRow(
            title: Text("Primary Title"),
            subtitle: Text("Optional Subtitle."),
            details: Text("Optional Caption."),
            image: Image(systemName: "heart.fill"), tint: .healthKit
        ) {
            Toggle("", isOn: $toggle)
        }
    }
}

#Preview {
    List {
        MeasurementRow_Previews()
            .modelContainer(
                for: [DietaryCalorie.self, Weight.self],
                inMemory: true
            )
    }
}
