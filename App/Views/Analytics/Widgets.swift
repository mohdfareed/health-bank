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
        NavigationLink(destination: destination) {
            LazyVStack(spacing: 8) {
                LabeledContent {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .font(.footnote.bold())
                } label: {
                    Label {
                        Text(String(localized: title))
                            .font(.headline)
                            .foregroundColor(color)
                    } icon: {
                        icon
                            .font(.title2)
                            .foregroundColor(color)
                    }
                }

                // Content
                content
            }
            .padding()
        }
        .buttonBorderShape(.roundedRectangle)
        .buttonStyle(.bordered)
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
