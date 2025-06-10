import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var context: ModelContext

    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(DashboardCard.CardType.allCases, id: \.self) { cardType in
                        DashboardCard(type: cardType)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding()
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: true)
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct DashboardCard: View {
    let type: CardType
    @State private var isPressed = false

    enum CardType: CaseIterable {
        case calories
        case steps
        case weight
        case heartRate
        case goals
        case activity

        var title: String {
            switch self {
            case .calories: return "Calories"
            case .steps: return "Steps"
            case .weight: return "Weight"
            case .heartRate: return "Heart Rate"
            case .goals: return "Goals"
            case .activity: return "Activity"
            }
        }

        var icon: String {
            switch self {
            case .calories: return "flame.fill"
            case .steps: return "figure.walk"
            case .weight: return "scalemass.fill"
            case .heartRate: return "heart.fill"
            case .goals: return "target"
            case .activity: return "chart.bar.fill"
            }
        }

        var color: Color {
            switch self {
            case .calories: return .orange
            case .steps: return .blue
            case .weight: return .purple
            case .heartRate: return .red
            case .goals: return .green
            case .activity: return .mint
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: type.icon)
                    .symbolEffect(.variableColor, options: .nonRepeating)
                    .font(.title2)
                    .foregroundColor(type.color)

                Spacer()

                Button(action: {
                    // Navigate to detailed view
                }) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(type.title)
                .font(.headline)
                .foregroundColor(.primary)

            // Placeholder for metric value
            Text("--")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            // Placeholder for trend indicator
            HStack {
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.green)

                Text("+5%")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background.secondary)
                .shadow(
                    color: .black.opacity(0.1),
                    radius: isPressed ? 2 : 8,
                    x: 0,
                    y: isPressed ? 1 : 4
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }
    }
}
