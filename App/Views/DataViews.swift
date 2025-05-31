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

// MARK: Active Calories
// ============================================================================

extension MeasurementRow {
    static func activity(
        measurement: LocalizedMeasurement<Unit>,
        title: String.LocalizationValue? = nil,
        source: DataSource,
        showPicker: Bool = false,
        @ViewBuilder details: @escaping () -> DetailContent = { EmptyView() },
    ) -> Self {
        .init(
            measurement: measurement,
            title: title ?? "Active Energy",
            image: .activeCalorie, tint: .activeCalorie,
            source: source, format: .number.precision(.fractionLength(0)),
            showPicker: showPicker, computed: nil, validator: { $0 >= 0 }
        ) { details() }
    }
}

// MARK: Weight
// ============================================================================

extension MeasurementRow {
    static func weight(
        measurement: LocalizedMeasurement<Unit>,
        title: String.LocalizationValue? = nil,
        source: DataSource,
        showPicker: Bool = false,
        @ViewBuilder details: @escaping () -> DetailContent = { EmptyView() },
    ) -> Self {
        .init(
            measurement: measurement,
            title: title ?? "Weight", image: .weight, tint: .weight,
            source: source, format: .number.precision(.fractionLength(2)),
            showPicker: showPicker, computed: nil, validator: { $0 >= 0 }
        ) { details() }
    }
}
