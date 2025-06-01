import SwiftData
import SwiftUI

// MARK: Weight Form
// ============================================================================

struct WeightForm: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let weight: Weight
    @State private var weightValue: Double?
    @State private var date: Date
    @State private var showDeleteConfirmation = false

    init(weight: Weight) {
        self.weight = weight
        self._weightValue = State(initialValue: weight.weight)
        self._date = State(initialValue: weight.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Weight Entry") {
                    RecordField(
                        FieldDefinition.weight,
                        value: $weightValue,
                        source: weight.source,
                        showPicker: true
                    )

                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                if weight.source == .local {
                    Section {
                        Button("Delete Entry", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle("Weight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveWeight() }
                        .disabled(weightValue == nil || weightValue! <= 0)
                }
            }
            .confirmationDialog(
                "Delete Weight Entry",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) { deleteWeight() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private func saveWeight() {
        guard let newWeight = weightValue else { return }

        weight.weight = newWeight
        weight.date = date

        try? context.save()
        dismiss()
    }

    private func deleteWeight() {
        context.delete(weight)
        try? context.save()
        dismiss()
    }
}

// MARK: Dietary Calorie Form
// ============================================================================

struct DietaryCalorieForm: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let calorie: DietaryCalorie
    @State private var calorieValue: Double?
    @State private var proteinValue: Double?
    @State private var carbsValue: Double?
    @State private var fatValue: Double?
    @State private var date: Date
    @State private var showDeleteConfirmation = false

    init(calorie: DietaryCalorie) {
        self.calorie = calorie
        self._calorieValue = State(initialValue: calorie.calories)
        self._proteinValue = State(initialValue: calorie.macros?.protein)
        self._carbsValue = State(initialValue: calorie.macros?.carbs)
        self._fatValue = State(initialValue: calorie.macros?.fat)
        self._date = State(initialValue: calorie.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Calorie Entry") {
                    RecordField(
                        FieldDefinition.dietaryCalorie,
                        value: $calorieValue,
                        source: calorie.source,
                        showPicker: true
                    )

                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section("Macronutrients (Optional)") {
                    RecordField(
                        FieldDefinition.protein,
                        value: $proteinValue,
                        source: calorie.source,
                        showPicker: true
                    )

                    RecordField(
                        FieldDefinition.carbs,
                        value: $carbsValue,
                        source: calorie.source,
                        showPicker: true
                    )

                    RecordField(
                        FieldDefinition.fat,
                        value: $fatValue,
                        source: calorie.source,
                        showPicker: true
                    )
                }

                if calorie.source == .local {
                    Section {
                        Button("Delete Entry", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle("Dietary Calories")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCalorie() }
                        .disabled(calorieValue == nil || calorieValue! <= 0)
                }
            }
            .confirmationDialog(
                "Delete Calorie Entry",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) { deleteCalorie() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private func saveCalorie() {
        guard let newCalories = calorieValue else { return }

        calorie.calories = newCalories
        calorie.date = date

        // Update macros if any are provided
        if proteinValue != nil || carbsValue != nil || fatValue != nil {
            calorie.macros = CalorieMacros(
                p: proteinValue,
                f: fatValue,
                c: carbsValue
            )
        } else {
            calorie.macros = nil
        }

        try? context.save()
        dismiss()
    }

    private func deleteCalorie() {
        context.delete(calorie)
        try? context.save()
        dismiss()
    }
}

// MARK: Active Energy Form
// ============================================================================

struct ActiveEnergyForm: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let activeEnergy: ActiveEnergy
    @State private var calorieValue: Double?
    @State private var durationMinutes: Double?
    @State private var workoutType: WorkoutType?
    @State private var date: Date
    @State private var showDeleteConfirmation = false

    init(activeEnergy: ActiveEnergy) {
        self.activeEnergy = activeEnergy
        self._calorieValue = State(initialValue: activeEnergy.calories)
        self._durationMinutes = State(initialValue: activeEnergy.duration.map { $0 / 60 })
        self._workoutType = State(initialValue: activeEnergy.workout)
        self._date = State(initialValue: activeEnergy.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Active Energy") {
                    RecordField(
                        FieldDefinition.activeCalorie,
                        value: $calorieValue,
                        source: activeEnergy.source,
                        showPicker: true
                    )

                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                Section("Workout Details (Optional)") {
                    RecordField(
                        FieldDefinition.activity,
                        value: $durationMinutes,
                        source: activeEnergy.source,
                        showPicker: true
                    )

                    Picker("Workout Type", selection: $workoutType) {
                        Text("None").tag(nil as WorkoutType?)
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type as WorkoutType?)
                        }
                    }
                    .disabled(activeEnergy.source != .local)
                }

                if activeEnergy.source == .local {
                    Section {
                        Button("Delete Entry", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle("Active Energy")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveActiveEnergy() }
                        .disabled(calorieValue == nil || calorieValue! <= 0)
                }
            }
            .confirmationDialog(
                "Delete Active Energy Entry",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) { deleteActiveEnergy() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private func saveActiveEnergy() {
        guard let newCalories = calorieValue else { return }

        activeEnergy.calories = newCalories
        activeEnergy.date = date
        activeEnergy.duration = durationMinutes.map { $0 * 60 }  // Convert to seconds
        activeEnergy.workout = workoutType

        try? context.save()
        dismiss()
    }

    private func deleteActiveEnergy() {
        context.delete(activeEnergy)
        try? context.save()
        dismiss()
    }
}

// MARK: Resting Energy Form
// ============================================================================

struct RestingEnergyForm: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let restingEnergy: RestingEnergy
    @State private var calorieValue: Double?
    @State private var date: Date
    @State private var showDeleteConfirmation = false

    init(restingEnergy: RestingEnergy) {
        self.restingEnergy = restingEnergy
        self._calorieValue = State(initialValue: restingEnergy.calories)
        self._date = State(initialValue: restingEnergy.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Resting Energy") {
                    RecordField(
                        FieldDefinition.restingCalorie,
                        value: $calorieValue,
                        source: restingEnergy.source,
                        showPicker: true
                    )

                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }

                if restingEnergy.source == .local {
                    Section {
                        Button("Delete Entry", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle("Resting Energy")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveRestingEnergy() }
                        .disabled(calorieValue == nil || calorieValue! <= 0)
                }
            }
            .confirmationDialog(
                "Delete Resting Energy Entry",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) { deleteRestingEnergy() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    private func saveRestingEnergy() {
        guard let newCalories = calorieValue else { return }

        restingEnergy.calories = newCalories
        restingEnergy.date = date

        try? context.save()
        dismiss()
    }

    private func deleteRestingEnergy() {
        context.delete(restingEnergy)
        try? context.save()
        dismiss()
    }
}
