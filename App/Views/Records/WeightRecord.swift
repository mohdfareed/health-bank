import SwiftUI

/// UI definition for Weight health data type
struct WeightRecordUI: HealthRecordUIDefinition {
    // MARK: Associated Types

    typealias FormContent = AnyView
    typealias RowSubtitle = EmptyView
    typealias MainValue = AnyView

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

    // MARK: Field Definitions

    /// Field definitions specific to weight records
    enum Fields {
        static let weight = RecordFieldDefinition(
            unitDefinition: .weight,
            validator: { $0 > 0 },
            formatter: .number.precision(.fractionLength(1)),
            image: .weight,
            tint: .weight,
            title: "Weight"
        )
    }

    // MARK: UI Component Builders

    @MainActor
    func formContent<T: HealthData>(_ record: T) -> FormContent {
        if let weight = record as? Weight {
            let bindableWeight = Bindable(weight)
            return AnyView(
                WeightMeasurementField(weight: bindableWeight, uiDefinition: self)
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    @MainActor
    func rowSubtitle<T: HealthData>(_ record: T) -> RowSubtitle {
        EmptyView()
    }

    @MainActor
    func mainValue<T: HealthData>(_ record: T) -> MainValue {
        if let weight = record as? Weight {
            return AnyView(
                ValueView(
                    measurement: .init(
                        baseValue: .constant(weight.weight),
                        definition: .weight
                    ),
                    icon: nil, tint: nil,
                    format: preferredFormatter
                )
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

struct WeightMeasurementField: View {
    @Bindable var weight: Weight
    let uiDefinition: WeightRecordUI

    init(weight: Bindable<Weight>, uiDefinition: WeightRecordUI) {
        self.uiDefinition = uiDefinition
        _weight = weight
    }

    var body: some View {
        RecordField(
            WeightRecordUI.Fields.weight,
            value: $weight.weight.optional(0),
            isInternal: weight.source == .app,
            showPicker: true
        )
    }
}
