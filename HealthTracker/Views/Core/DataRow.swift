import SwiftUI

// MARK: View
// ============================================================================

struct DataRow<Content: View>: View {
    @ViewBuilder let content: () -> Content
    let (title, subtitle, caption): (Text, Text?, Text?)
    let (image, color): (Image?, Color)

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
        HStack {
            HStack {
                if let image = self.image {
                    image.symbolVariant(.fill).imageScale(.medium)
                        .foregroundStyle(self.color)
                }

                VStack(alignment: .leading) {
                    HStack(alignment: .bottom) {
                        self.title.lineLimit(1).fixedSize()
                        Text(String(localized: "•")).lineLimit(1).fixedSize()
                            .foregroundStyle(.secondary)
                        self.subtitle.lineLimit(1).fixedSize()
                            .foregroundStyle(.secondary)
                    }
                    self.caption.lineLimit(1).fixedSize()
                        .foregroundStyle(.secondary).textScale(.secondary)
                }

                Spacer()
                self.content()
            }
        }
    }
}

// MARK: Preview
// ============================================================================

#Preview {
    Form {
        DataRow(
            title: Text("Row Title"),
            subtitle: Text("Row Subtitle"), caption: Text("Data row caption."),
            image: Image(systemName: "swift"), color: .red
        ) { AnyView(Text("Row Contents")) }
    }
}
