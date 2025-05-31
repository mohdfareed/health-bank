import SwiftUI

// REVIEW: animations

struct DetailedRow<
    Content: View, Title: View, Subtitle: View, Details: View
>: View {
    let image: Image?
    let tint: Color?

    @ViewBuilder var title: () -> Title
    @ViewBuilder var subtitle: () -> Subtitle?
    @ViewBuilder var details: () -> Details?
    @ViewBuilder var content: () -> Content

    var body: some View {
        Label {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        title().contentTransition(.numericText())

                        if let subtitle = subtitle() {
                            subtitle
                                .textScale(.secondary)
                                .foregroundStyle(.secondary)
                                .contentTransition(.opacity)
                                .transition(.opacity)
                        }
                    }

                    if let details = details() {
                        details
                            .textScale(.secondary)
                            .foregroundStyle(.secondary)
                            .contentTransition(.opacity)
                            .transition(.opacity)
                    }
                }
                .truncationMode(.tail)
                .lineLimit(1)
                .layoutPriority(1)

                Spacer()
                content().contentTransition(.numericText())
            }
        } icon: {
            if let image = image {
                image
                    .foregroundStyle(tint ?? .primary)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .animation(.spring, value: content() as? AnyHashable)
        .animation(.default, value: subtitle() != nil)
        .animation(.default, value: details() != nil)
        .animation(.default, value: tint != nil)
        .animation(.spring, value: image != nil)
    }
}

// Convenience initializer
extension DetailedRow
where Title == Text, Subtitle == Text, Details == Text {
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
