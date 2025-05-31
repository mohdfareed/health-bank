import SwiftData
import SwiftUI

// MARK: Calories
// ============================================================================

extension MeasurementRow {
    static func calorie(
        measurement: LocalizedMeasurement<Unit>,
        title: String.LocalizationValue? = nil,
        source: DataSource,
        computed: (() -> Double?)? = nil,
        @ViewBuilder details: @escaping () -> DetailContent = { EmptyView() },
    ) -> Self {
        .init(
            measurement: measurement,
            title: title ?? "Calories", image: .calories, tint: .calories,
            source: source, format: .number.precision(.fractionLength(0)),
            showPicker: false, computed: computed, validator: { $0 >= 0 },
        ) { details() }
    }

    static func dietaryCalorie(
        measurement: LocalizedMeasurement<Unit>,
        title: String.LocalizationValue? = nil,
        source: DataSource,
        computed: (() -> Double?)? = nil,
        @ViewBuilder details: @escaping () -> DetailContent = { EmptyView() },
    ) -> Self {
        .init(
            measurement: measurement,
            title: title ?? "Calories",
            image: .dietaryCalorie, tint: .dietaryCalorie,
            source: source, format: .number.precision(.fractionLength(0)),
            showPicker: false, computed: computed, validator: { $0 >= 0 },
        ) { details() }
    }

    static func restingCalorie(
        measurement: LocalizedMeasurement<Unit>,
        title: String.LocalizationValue? = nil,
        source: DataSource,
        @ViewBuilder details: @escaping () -> DetailContent = { EmptyView() },
    ) -> Self {
        .init(
            measurement: measurement,
            title: title ?? "Energy",
            image: .restingCalorie, tint: .restingCalorie,
            source: source, format: .number.precision(.fractionLength(0)),
            showPicker: false, computed: nil, validator: { $0 >= 0 },
        ) { details() }
    }

}
