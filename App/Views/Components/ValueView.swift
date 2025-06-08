import Foundation
import SwiftUI

/// A simple view that displays a measurement value with an icon and optional tint
struct ValueView: View {
    let value: Double
    let unit: String
    let icon: Image?
    let tint: Color?
    let format: FloatingPointFormatStyle<Double>

    init<Unit: Dimension>(
        measurement: Measurement<Unit>,
        icon: Image?,
        tint: Color?,
        format: FloatingPointFormatStyle<Double>
    ) {
        self.value = measurement.value
        self.unit = measurement.unit.symbol
        self.icon = icon
        self.tint = tint
        self.format = format
    }

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            icon?.foregroundStyle(tint ?? .primary)
            Text(value, format: format)
            Text(unit).textScale(.secondary)
                .foregroundStyle(.secondary)
        }
    }
}
