import SwiftUI

// MARK: AdaptiveGridContainer
// A SwiftUI-native container that switches between grid and list layouts.

struct AdaptiveGridContainer<Content: View>: View {
    enum Style {
        case grid
        case list
    }

    let style: Style
    let columns: [GridItem]
    let content: Content

    init(
        style: Style = .grid,
        columns: [GridItem] = Array(
            repeating: GridItem(.flexible(), spacing: 16), count: 2
        ),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.style = style
        self.columns = columns
        self.content = content()
    }

    var body: some View {
        Group {
            if style == .grid {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        content
                    }
                    .padding(.horizontal)
                }
            } else {
                List {
                    content
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// MARK: HealthGridItem
// A SwiftUI-native grid item with icon, title, and navigation.

struct HealthGridItem<Destination: View>: View {
    let title: String
    let icon: Image
    let tint: Color
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 8) {
                icon
                    .font(.largeTitle)
                    .foregroundColor(tint)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: HealthRowItem
// A SwiftUI-native list row item with icon, title, and disclosure indicator.

struct HealthRowItem<Destination: View>: View {
    let title: String
    let icon: Image
    let tint: Color
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination) {
            Label {
                Text(title)
            } icon: {
                icon.foregroundColor(tint)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
