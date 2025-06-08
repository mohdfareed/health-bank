import SwiftUI

/// UI definition for Weight health data type
struct WeightRecordUI: HealthRecordUIDefinition {
    // MARK: Associated Types

    typealias FormContent = AnyView
    typealias RowSubtitle = EmptyView

    // MARK: Visual Identity

    var title: String.LocalizationValue { "Weight" }
    var icon: Image { .weight }
    var color: Color { .weight }

    // MARK: Chart Integration

    var chartColor: Color { .weight }
    var preferredFormatter: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(1))
    }

    // MARK: Data Factory

    func createNew() -> any HealthData {
        Weight(0)
    }

    // MARK: UI Component Builders

    @MainActor
    func formContent<T: HealthData>(_ record: T) -> FormContent {
        if let weight = record as? Weight {
            let bindableWeight = Bindable(weight)
            return AnyView(
                VStack(spacing: 16) {
                    WeightMeasurementField(weight: bindableWeight, uiDefinition: self)
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    @MainActor
    func rowSubtitle<T: HealthData>(_ record: T) -> RowSubtitle {
        EmptyView()
    }
}

struct WeightMeasurementField: View {
    @Bindable var weight: Weight
    let uiDefinition: WeightRecordUI

    init(weight: Bindable<Weight>, uiDefinition: WeightRecordUI) {
        self.weight = weight.wrappedValue
        self.uiDefinition = uiDefinition
    }

    var body: some View {
        RecordField(
            .weight,
            value: $weight.weight.optional(0),
            isInternal: weight.source == .app
        )
    }
}
