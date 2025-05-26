import SwiftUI

// MARK: View
// ============================================================================

struct DataRow<Content: View>: View {
    @ViewBuilder let content: () -> Content
    let title: Text
    let subtitle: Text?
    let caption: Text?
    let image: Image?
    let color: Color

    init(
        title: Text, subtitle: Text? = nil, caption: Text? = nil,
        image: Image? = nil, color: Color = .primary,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
        self.image = image
        self.color = color
        self.content = content
    }

    var body: some View {
        HStack(spacing: 12) {  // Added spacing for better visual separation
            if let image = self.image {
                image
                    .symbolVariant(.fill)
                    .imageScale(.medium)
                    .foregroundStyle(self.color)
                    .frame(width: 24, height: 24)  // Consistent size for icon area
                    .padding(.trailing, 4)  // Reduced padding slightly
            }

            VStack(alignment: .leading, spacing: 2) {  // Spacing between text elements
                self.title
                    .font(.headline)  // More semantic font style
                    .lineLimit(1)
                    .truncationMode(.tail)

                if let subtitle = self.subtitle {
                    subtitle
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                }

                if let caption = self.caption {
                    caption
                        .font(.caption)  // More semantic font style
                        .foregroundStyle(.tertiary)  // Differentiate from subtitle
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
            }

            Spacer()
            self.content()
        }
        .padding(.vertical, 8)  // Add some vertical padding to the row
    }
}

// MARK: Preview
// ============================================================================

#Preview {
    Form {
        DataRow(
            title: Text("Primary Title Text"),
            subtitle: Text(
                "Optional Subtitle, can be a bit longer and will wrap to two lines if needed."),
            caption: Text("Optional caption providing extra context, also wraps."),
            image: Image(systemName: "heart.fill"), color: .red
        ) {
            Text("Value")
                .font(.body)
                .foregroundStyle(.secondary)
        }

        DataRow(
            title: Text("Title Only Example"),
            image: Image(systemName: "star.fill"), color: .yellow
        ) {
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }

        DataRow(
            title: Text("Title and Caption"),
            caption: Text("This row only has a title and a caption below it."),
            image: Image(systemName: "bell.fill"), color: .orange
        ) {
            Toggle("", isOn: .constant(true))
        }
    }
}
