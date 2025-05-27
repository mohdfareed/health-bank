import SwiftUI

// MARK: ViewModel
// ============================================================================

class DataRowVM {
    let title: Text
    let subtitle: Text?
    let caption: Text?
    let image: Image?
    let color: Color

    init(
        title: Text, subtitle: Text? = nil,
        caption: Text? = nil, image: Image? = nil,
        color: Color = .primary,
    ) {
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
        self.image = image
        self.color = color
    }
}

// MARK: View
// ============================================================================

struct DataRow<Content: View>: View {
    @ViewBuilder let content: () -> Content
    private var vm: DataRowVM

    init(vm: DataRowVM, @ViewBuilder content: @escaping () -> Content) {
        self.vm = vm
        self.content = content
    }

    var body: some View {
        HStack(spacing: 12) {  // Added spacing for better visual separation
            if let image = vm.image {
                image
                    .symbolVariant(.fill)
                    .imageScale(.medium)
                    .foregroundStyle(vm.color)
                    .frame(width: 24, height: 24)  // Consistent size for icon area
                    .padding(.trailing, 4)  // Reduced padding slightly
                    .animation(.default, value: vm.color)
                    .animation(.default, value: vm.image)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    vm.title
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .animation(.default, value: vm.title)

                    if let subtitle = vm.subtitle {
                        Text("•").font(.subheadline).foregroundStyle(.secondary)
                        subtitle
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .animation(.default, value: vm.subtitle)
                    }
                }

                if let caption = vm.caption {
                    caption
                        .font(.caption)  // More semantic font style
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .animation(.default, value: vm.caption)
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
            vm: .init(
                title: Text("Primary Title Text"),
                subtitle: Text(
                    "Optional Subtitle, can be a bit longer and will wrap to two lines if needed."),
                caption: Text("Optional caption providing extra context, also wraps."),
                image: Image(systemName: "heart.fill"), color: .red
            )
        ) {
            Text("Value")
                .font(.body)
                .foregroundStyle(.secondary)
        }

        DataRow(
            vm: .init(
                title: Text("Title Only Example"),
                image: Image(systemName: "star.fill"), color: .yellow
            )
        ) {
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }

        DataRow(
            vm: .init(
                title: Text("Title and Caption"),
                caption: Text("This row only has a title and a caption below it."),
                image: Image(systemName: "bell.fill"), color: .orange
            )
        ) {
            Toggle("", isOn: .constant(true))
        }
    }
}
