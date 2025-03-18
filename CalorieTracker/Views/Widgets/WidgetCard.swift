import SwiftData
import SwiftUI

protocol WidgetVMProtocol {
    var name: String { get }
}

struct WidgetCard<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @State var title: String

    init(_ title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(spacing: 12) {
            // Card title.
            Text(self.title)
                .font(.headline).bold()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Card rows.
            ForEach(subviews: content()) { subview in
                subview.transition(.opacity)
                Divider()
            }
        }
        .padding()
        .background(.background.secondary)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
