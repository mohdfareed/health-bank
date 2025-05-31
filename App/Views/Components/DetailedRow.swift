import SwiftData
import SwiftUI

// REVIEW: Simplify and reuse
// TODO: Add animations

struct DetailedRow<
    Content: View,
    TitleContent: View,
    SubtitleContent: View,
    DetailsContent: View
>: View {
    let image: Image?
    let tint: Color?

    @ViewBuilder var title: () -> TitleContent
    @ViewBuilder var subtitle: () -> SubtitleContent?
    @ViewBuilder var details: () -> DetailsContent?
    @ViewBuilder var content: () -> Content

    var body: some View {
        Label {
            HStack(spacing: 8) {
                VStack(alignment: .leading) {
                    HStack {
                        title()
                        if let subtitle = subtitle() {
                            subtitle.textScale(.secondary)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let details = details() {
                        details.textScale(.secondary)
                            .foregroundStyle(.secondary)
                    }
                }
                .truncationMode(.tail)
                .lineLimit(1)

                Spacer()
                content().fixedSize()
            }
        } icon: {
            if let image = image {
                image.foregroundStyle(tint ?? .primary)
            }
        }
    }
}

// Convenience initializer
extension DetailedRow
where TitleContent == Text, SubtitleContent == Text, DetailsContent == Text {
    init(
        title: Text, subtitle: Text? = nil, details: Text? = nil,
        image: Image? = nil, tint: Color? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = { title }
        self.subtitle = { subtitle }
        self.details = { details }

        self.image = image
        self.tint = tint
        self.content = content
    }
}
