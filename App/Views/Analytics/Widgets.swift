import SwiftData
import SwiftUI

// MARK: - Dashboard Card
// ============================================================================

struct DashboardCard<Content: View, Destination: View>: View {
    let title: String.LocalizationValue
    let icon: Image
    let color: Color

    @ViewBuilder let content: Content
    @ViewBuilder let destination: Destination

    var body: some View {
        Section(String(localized: title)) {
            content.padding()
            // NavigationLink(destination: destination) {
            // }
        }
        .fontDesign(.rounded)
    }
}

// MARK: - Progress View
// ============================================================================

struct MetricBar: View {
    let title: String.LocalizationValue
    let value: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(String(localized: title))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
            }

            ProgressView(value: value)
                .progressViewStyle(.circular)
                .tint(color)
        }
    }
}
