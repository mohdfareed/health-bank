import SwiftData
import SwiftUI

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
            source: source, format: .number.precision(.fractionLength(0)),
            showPicker: showPicker, computed: nil, validator: { $0 >= 0 }
        ) { details() }
    }
}
