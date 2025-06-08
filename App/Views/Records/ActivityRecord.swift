import Foundation
import SwiftUI

/// UI definition for ActiveEnergy health data type
struct ActivityRecordUI: HealthRecordUIDefinition {
    // MARK: Associated Types

    typealias FormContent = AnyView
    typealias RowSubtitle = AnyView
    typealias MainValue = AnyView

    // MARK: Visual Identity

    var title: String.LocalizationValue { "Activity" }
    var icon: Image { .activeCalorie }
    var color: Color { .activeCalorie }

    // MARK: Chart Integration

    var chartColor: Color { .activeCalorie }
    var preferredFormatter: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(0))
    }

    // MARK: Data Factory

    func createNew() -> any HealthData {
        ActiveEnergy(0)
    }

    // MARK: Field Definitions

    /// Field definitions specific to activity records
    enum Fields {
        static let calorie = RecordFieldDefinition(
            unitDefinition: .calorie,
            validator: { $0 > 0 && $0 <= 10000 },
            formatter: .number.precision(.fractionLength(0)),
            image: .calories,
            tint: .calories,
            title: "Calories"
        )

        static let duration = RecordFieldDefinition(
            unitDefinition: .activity,
            validator: { $0 > 0 && $0 <= 1440 },  // max 24 hours in minutes
            formatter: .number.precision(.fractionLength(0)),
            image: .duration,
            tint: .duration,
            title: "Duration"
        )
    }

    // MARK: UI Component Builders

    @MainActor
    func formContent<T: HealthData>(_ record: T) -> FormContent {
        if let activity = record as? ActiveEnergy {
            let bindableActivity = Bindable(activity)
            return AnyView(
                ActivityMeasurementField(activity: bindableActivity, uiDefinition: self)
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    @MainActor
    func rowSubtitle<T: HealthData>(_ record: T) -> RowSubtitle {
        if let activity = record as? ActiveEnergy {
            return AnyView(
                HStack(alignment: .bottom, spacing: 0) {
                    if activity.workout != nil {
                        activity.workout?.icon.asText
                            .foregroundStyle(Color.activeCalorie)
                        Spacer().frame(maxWidth: 8)
                    }
                    if activity.duration != nil {
                        DurationValueView(
                            value: activity.duration ?? 0,
                            icon: nil, tint: nil
                        )
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    @MainActor
    func mainValue<T: HealthData>(_ record: T) -> MainValue {
        if let activity = record as? ActiveEnergy {
            let measurement = Measurement(value: activity.calories, unit: UnitEnergy.kilocalories)

            return AnyView(
                ValueView(
                    measurement: measurement,
                    icon: nil, tint: nil,
                    format: preferredFormatter
                )
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}

struct ActivityMeasurementField: View {
    @Bindable var activity: ActiveEnergy
    let uiDefinition: ActivityRecordUI

    init(activity: Bindable<ActiveEnergy>, uiDefinition: ActivityRecordUI) {
        self.uiDefinition = uiDefinition
        _activity = activity
    }

    var body: some View {
        Section {
            // Calories field
            RecordField(
                ActivityRecordUI.Fields.calorie,
                value: $activity.calories.optional(0),
                isInternal: activity.source == .app,
                showPicker: true
            )

            // Duration field
            RecordField(
                ActivityRecordUI.Fields.duration,
                value: durationBinding,
                isInternal: activity.source == .app,
                showPicker: true
            )

            // Workout picker
            Picker(selection: $activity.workout) {
                ForEach(WorkoutActivity.allCases, id: \.self) { workoutActivity in
                    Label {
                        Text(workoutActivity.localized)
                    } icon: {
                        workoutActivity.icon
                    }.tag(workoutActivity)
                }

                Divider()

                Label {
                    Text("Other")
                } icon: {
                    Image(systemName: "ellipsis")
                }.tag(nil as WorkoutActivity?)
            } label: {
                Label {
                    Text("Activity")
                } icon: {
                    Image.activeCalorie
                        .foregroundStyle(Color.activeCalorie)
                }
            }
            .disabled(activity.source != .app)
        }
    }

    private var durationBinding: Binding<Double?> {
        Binding(
            get: { activity.duration },
            set: { activity.duration = $0 }
        )
    }
}

// Helper view for duration values in row subtitle
struct DurationValueView: View {
    let value: Double
    let icon: Image?
    let tint: Color?
    @LocalizedMeasurement var measurement: Measurement<UnitDuration>

    init(value: Double, icon: Image?, tint: Color?) {
        self.value = value
        self.icon = icon
        self.tint = tint
        self._measurement = LocalizedMeasurement(.constant(value), definition: .activity)
    }

    var body: some View {
        ValueView(
            measurement: measurement,
            icon: icon, tint: tint,
            format: .number.precision(.fractionLength(0))
        )
    }
}
