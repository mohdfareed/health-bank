import SwiftData
import SwiftUI

// MARK: Macros
// ============================================================================

extension MeasurementRow {
    static func protein(
        measurement: LocalizedMeasurement<Unit>,
        title: String.LocalizationValue? = nil,
        source: DataSource,
        computed: (() -> Double?)? = nil,
        @ViewBuilder details: @escaping () -> DetailContent = { EmptyView() },
    ) -> Self {
        .init(
            measurement: measurement,
            title: title ?? "Protein", image: .protein, tint: .protein,
            source: source, format: .number.precision(.fractionLength(0)),
            showPicker: false, computed: computed, validator: { $0 >= 0 }
        ) { details() }
    }

    static func carbs(
        measurement: LocalizedMeasurement<Unit>,
        title: String.LocalizationValue? = nil,
        source: DataSource,
        computed: (() -> Double?)? = nil,
        @ViewBuilder details: @escaping () -> DetailContent = { EmptyView() },
    ) -> Self {
        .init(
            measurement: measurement,
            title: title ?? "Carbohydrates", image: .carbs, tint: .carbs,
            source: source, format: .number.precision(.fractionLength(0)),
            showPicker: false, computed: computed, validator: { $0 >= 0 }
        ) { details() }
    }

    static func fat(
        measurement: LocalizedMeasurement<Unit>,
        title: String.LocalizationValue? = nil,
        source: DataSource,
        computed: (() -> Double?)? = nil,
        @ViewBuilder details: @escaping () -> DetailContent = { EmptyView() },
    ) -> Self {
        .init(
            measurement: measurement,
            title: title ?? "Fat", image: .fat, tint: .fat,
            source: source, format: .number.precision(.fractionLength(0)),
            showPicker: false, computed: computed, validator: { $0 >= 0 }
        ) { details() }
    }
}
