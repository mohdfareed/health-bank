import SwiftUI

struct ActiveEnergyRecordView: View {
    var title: LocalizedStringKey
    @Binding var record: ActiveEnergy

    @State private var editableCalories: Double
    @State private var editableDuration: TimeInterval?
    @State private var editableWorkoutType: WorkoutType?

    init(title: LocalizedStringKey, record: Binding<ActiveEnergy>) {
        self.title = title
        self._record = record
        self._editableCalories = State(initialValue: record.wrappedValue.calories)
        self._editableDuration = State(initialValue: record.wrappedValue.duration)
        self._editableWorkoutType = State(initialValue: record.wrappedValue.workout)
    }

    var body: some View {
        RecordView(
            record, title: title, icon: Image.workout, color: .green
        ) { isEditing in
            VStack(alignment: .leading, spacing: 12) {
                MeasurementField(
                    LocalizedMeasurement(
                        baseValue: $editableCalories,
                        definition: DietaryEnergy.unit
                    ),
                    vm: MeasurementFieldVM(
                        title: Text("Calories"),
                        image: Image.burnedCalorie,
                        color: .orange,
                        fractions: 0
                    ),
                    editable: isEditing
                )

                // Duration Field
                if isEditing || record.duration != nil {
                    MeasurementField(
                        LocalizedMeasurement(
                            baseValue: $editableDuration.defaulted(to: 0),
                            definition: ActiveEnergy.unit
                        ),
                        vm: MeasurementFieldVM(
                            title: Text("Duration"),
                            image: Image.duration,
                            color: .blue,
                            fractions: 0
                        ),
                        editable: isEditing
                    )
                }

                // Workout Type Picker / Display
                if isEditing || record.workout != nil {
                    DataRow(
                        vm: .init(
                            title: Text("Workout"),
                            image: Image.workout,
                            color: .green
                        )
                    ) {
                        if isEditing {
                            Picker("Workout", selection: $editableWorkoutType) {
                                Text("None").tag(nil as WorkoutType?)
                                ForEach(WorkoutType.allCases, id: \.self) {
                                    Text($0.localized).tag($0 as WorkoutType?)
                                }
                            }
                            .labelsHidden()
                        } else {
                            Text(record.workout!.localized)
                                .foregroundColor(
                                    record.workout == nil
                                        ? .secondary
                                        : .primary
                                )
                        }
                    }
                }
            }

            .onChange(of: isEditing) { _, newIsEditingValue in
                if newIsEditingValue {
                    // Copy from record to @State vars
                    editableCalories = record.calories
                    editableDuration = record.duration
                    editableWorkoutType = record.workout
                } else {
                    // Copy from @State vars to record
                    record.calories = editableCalories
                    record.duration = editableDuration
                    record.workout = editableWorkoutType
                }
            }
        }
    }
}

// MARK: Preview
// ============================================================================
struct ActiveEnergyRecordView_Preview: View {
    @State private var activeEnergy1: ActiveEnergy = .init(
        300, date: Date(), source: .local, duration: 3600, workoutType: .running  // 1 hour
    )
    @State private var activeEnergy2: ActiveEnergy = .init(
        150, date: Date(), source: .healthKit, duration: nil, workoutType: nil
    )

    var body: some View {
        NavigationView {
            VStack {
                Section("Full Record") {
                    ActiveEnergyRecordView(title: "Morning Run", record: $activeEnergy1)
                        .modifier(CardStyle())
                }
                Section("Minimal Record") {
                    ActiveEnergyRecordView(title: "Quick Walk", record: $activeEnergy2)
                        .modifier(CardStyle())
                }
            }
            .navigationTitle("Active Energy")
            .padding()
        }
    }
}

#Preview {
    ActiveEnergyRecordView_Preview()
}
