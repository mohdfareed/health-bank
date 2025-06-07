import SwiftUI

// REVIEW: animations

struct DetailedRow<Title: View, Subtitle: View, Details: View>: View {
    let image: Image?
    let tint: Color?

    @ViewBuilder var title: () -> Title
    @ViewBuilder var subtitle: () -> Subtitle?
    @ViewBuilder var details: () -> Details?

    var body: some View {
        Label {
            HStack(spacing: 6) {
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

        } icon: {
            if let image = image {
                image.foregroundStyle(tint ?? .primary)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .truncationMode(.tail)
        .lineLimit(1)

        .animation(.default, value: tint)
        .animation(.default, value: image)
        .animation(.default, value: subtitle() as? AnyHashable)
        .animation(.default, value: details() as? AnyHashable)
    }
}

// Convenience initializer
extension DetailedRow
where Title == Text, Subtitle == Text, Details == Text {
    init(
        title: Text, subtitle: Text? = nil, details: Text? = nil,
        image: Image? = nil, tint: Color? = nil,
    ) {
        self.title = { title }
        self.subtitle = { subtitle }
        self.details = { details }

        self.image = image
        self.tint = tint
    }
}
