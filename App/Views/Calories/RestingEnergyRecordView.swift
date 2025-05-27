import SwiftUI

struct RestingEnergyRecordView: View {
    var title: LocalizedStringKey
    @Binding var record: RestingEnergy

    @State private var editableCalories: Double

    init(title: LocalizedStringKey, record: Binding<RestingEnergy>) {
        self.title = title
        self._record = record
        self._editableCalories = State(initialValue: record.wrappedValue.calories)
    }

    var body: some View {
        RecordView(
            record, title: title, icon: Image.restingCalorie, color: .purple
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
            }
            .onChange(of: isEditing) { _, newIsEditingValue in
                if newIsEditingValue {
                    // Copy from record to @State var
                    editableCalories = record.calories
                } else {
                    // Copy from @State var to record
                    record.calories = editableCalories
                }
            }
        }
    }
}

// MARK: Preview
// ============================================================================
struct RestingEnergyRecordView_Preview: View {
    @State private var restingEnergy1: RestingEnergy = .init(
        1800, date: Date(), source: .local
    )
    @State private var restingEnergy2: RestingEnergy = .init(
        1750, date: Date(), source: .healthKit
    )

    var body: some View {
        NavigationView {
            VStack {
                RestingEnergyRecordView(title: "Daily Resting", record: $restingEnergy1)
                    .modifier(CardStyle())
                RestingEnergyRecordView(title: "HealthKit Resting", record: $restingEnergy2)
                    .modifier(CardStyle())
            }
            .navigationTitle("Resting Energy")
            .padding()
        }
    }
}

#Preview {
    RestingEnergyRecordView_Preview()
}
