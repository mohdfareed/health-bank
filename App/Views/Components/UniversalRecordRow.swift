import SwiftUI

// MARK: Universal Record Row Component
// ============================================================================

/// Universal record row that handles display of health records in data lists
/// Automatically determines subtitle content based on record type
struct RecordRow<Record: HealthRecord, Destination: View>: View {
    let record: Record
    @ViewBuilder let destination: () -> Destination

    init(
        record: Record, @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.record = record
        self.destination = destination
    }

    var body: some View {
        NavigationLink(destination: destination()) {
            DetailedRow(image: recordImage, tint: recordTint) {
                recordTitle
            } subtitle: {
                recordSubtitle
            } details: {
                DateView(date: record.date)
            } content: {
                if let sourceIcon = record.source.icon {
                    Text(sourceIcon)
                        .font(.caption2)
                        .foregroundStyle(record.source.color)
                }
            }
        }
    }

    // MARK: Record-Specific Display Logic

    private var recordImage: Image {
        switch record {
        case is Weight:
            return .weight
        case is DietaryCalorie:
            return .dietaryCalorie
        case is ActiveEnergy:
            return .activeCalorie
        case is RestingEnergy:
            return .restingCalorie
        default:
            return Image(systemName: "circle")
        }
    }

    private var recordTint: Color {
        switch record {
        case is Weight:
            return .weight
        case is DietaryCalorie:
            return .dietaryCalorie
        case is ActiveEnergy:
            return .activeCalorie
        case is RestingEnergy:
            return .restingCalorie
        default:
            return .primary
        }
    }

    @ViewBuilder
    private var recordTitle: some View {
        switch record {
        case let weight as Weight:
            Text("\(weight.weight.formatted(.number.precision(.fractionLength(0)))) kg")
        case let calorie as DietaryCalorie:
            Text("\(calorie.calories.formatted(.number.precision(.fractionLength(0)))) cal")
        case let active as ActiveEnergy:
            Text("\(active.calories.formatted(.number.precision(.fractionLength(0)))) cal")
        case let resting as RestingEnergy:
            Text("\(resting.calories.formatted(.number.precision(.fractionLength(0)))) cal")
        default:
            Text("Unknown Record")
        }
    }

    @ViewBuilder
    private var recordSubtitle: some View {
        switch record {
        case let calorie as DietaryCalorie:
            if let macros = calorie.macros {
                HStack(spacing: 4) {
                    if let protein = macros.protein {
                        Text("\(protein.formatted(.number.precision(.fractionLength(0))))g protein")
                    }
                    if let carbs = macros.carbs {
                        Text("•")
                        Text("\(carbs.formatted(.number.precision(.fractionLength(0))))g carbs")
                    }
                    if let fat = macros.fat {
                        Text("•")
                        Text("\(fat.formatted(.number.precision(.fractionLength(0))))g fat")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        case let active as ActiveEnergy:
            if let duration = active.duration {
                HStack(spacing: 4) {
                    Text("\(duration.formatted(.number.precision(.fractionLength(0))))min")
                    // Note: Removed workoutType as it doesn't exist on ActiveEnergy
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        default:
            EmptyView()
        }
    }
}
