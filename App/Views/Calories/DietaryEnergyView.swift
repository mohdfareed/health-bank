import SwiftUI

struct DietaryEnergyRecordView: View {
    var title: LocalizedStringKey
    @Binding var record: DietaryEnergy

    // State variables for editing
    @State private var editableCalories: Double
    @State private var editableMacros: CalorieMacros  // Single state for macros

    init(title: LocalizedStringKey, record: Binding<DietaryEnergy>) {
        self.title = title
        self._record = record

        self._editableCalories = State(
            initialValue: record.wrappedValue.calories
        )

        self._editableMacros = State(
            initialValue: CalorieMacros(
                p: record.wrappedValue.macros?.protein,
                f: record.wrappedValue.macros?.fat,
                c: record.wrappedValue.macros?.carbs
            )
        )
    }

    var body: some View {
        RecordView(
            record, title: title, icon: Image.dietaryCalorie, color: .blue
        ) { isEditing in
            VStack {  // Increased spacing a bit
                MeasurementField(
                    LocalizedMeasurement(
                        baseValue: $editableCalories,
                        definition: DietaryEnergy.unit
                    ),
                    vm: MeasurementFieldVM(
                        title: Text("Calories"),
                        image: Image.burnedCalorie,  // Using icon from Assets.swift
                        color: .orange,
                        fractions: 0
                    ),
                    editable: isEditing
                )

                if isEditing || record.macros != nil {
                    MeasurementField(
                        LocalizedMeasurement(
                            baseValue: $editableMacros.protein.defaulted(to: 0),
                            definition: CalorieMacros.unit
                        ),
                        vm: MeasurementFieldVM(
                            title: Text("Protein"),
                            image: Image.protein,
                            color: .indigo,
                            fractions: 0
                        ),
                        editable: isEditing
                    )
                    MeasurementField(
                        LocalizedMeasurement(
                            baseValue: $editableMacros.carbs.defaulted(to: 0),
                            definition: CalorieMacros.unit
                        ),
                        vm: MeasurementFieldVM(
                            title: Text("Carbohydrates"),
                            image: Image.carbs,
                            color: .green,
                            fractions: 0
                        ),
                        editable: isEditing
                    )
                    MeasurementField(
                        LocalizedMeasurement(
                            baseValue: $editableMacros.fat.defaulted(to: 0),
                            definition: CalorieMacros.unit
                        ),
                        vm: MeasurementFieldVM(
                            title: Text("Fat"),
                            image: Image.fat,
                            color: .yellow,
                            fractions: 0
                        ),
                        editable: isEditing
                    )
                }
            }

            .onChange(of: isEditing) { _, newIsEditingValue in
                if newIsEditingValue {
                    //  copy from record to @State vars
                    editableCalories = record.calories
                    editableMacros.protein = record.macros?.protein
                    editableMacros.fat = record.macros?.fat
                    editableMacros.carbs = record.macros?.carbs

                } else {
                    //  copy from @State vars to record
                    record.calories = editableCalories
                    if editableMacros.protein != nil
                        || editableMacros.fat != nil
                        || editableMacros.carbs != nil
                    {
                        if record.macros == nil {
                            record.macros = CalorieMacros()
                        }
                        record.macros?.protein = editableMacros.protein
                        record.macros?.fat = editableMacros.fat
                        record.macros?.carbs = editableMacros.carbs
                    } else {
                        record.macros = nil
                    }
                }
            }
        }
    }
}

// MARK: Preview
// ============================================================================

struct DietaryEnergyRecordView_Preview: View {
    @State private var dietaryEnergy1: DietaryEnergy = .init(
        2500, date: Date(), source: .local, macros: .init(p: 150, f: 80, c: 300)
    )
    @State private var dietaryEnergy2: DietaryEnergy = .init(
        1800, date: Date(), source: .healthKit, macros: nil
    )

    var body: some View {
        NavigationView {
            VStack {
                Section("Record with Macros") {
                    DietaryEnergyRecordView(
                        title: "Breakfast", record: $dietaryEnergy1
                    )
                    .modifier(CardStyle())
                }
                Section("Record without Macros") {
                    DietaryEnergyRecordView(
                        title: "Snack", record: $dietaryEnergy2
                    )
                    .modifier(CardStyle())
                }
            }
            .navigationTitle("Dietary Energy")
            .padding()
        }
    }
}

#Preview {
    DietaryEnergyRecordView_Preview()
}
