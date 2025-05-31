import SwiftData
import SwiftUI

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
