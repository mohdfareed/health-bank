import SwiftData
import SwiftUI

protocol BudgetVMProtocol {
    var name: String { get }
    var progress: Double? { get }
}

struct BudgetCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var vm: BudgetVMProtocol
    private let color: Color

    private var progressColor: Color {
        if self.vm.progress == nil {
            return .clear
        }
        return self.vm.progress! > 0.8 ? .red : self.color
    }

    init(
        viewModel: BudgetVMProtocol,
        color: Color = .accentColor,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.vm = viewModel
        self.content = content
        self.color = color
    }

    var body: some View {
        // TODO: Mirror Apple Health activity widget.

        VStack(spacing: 12) {
            // Header: Centered title.
            Text(vm.name)
                .font(.headline).bold()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Budget rows
            content()

            // Progress Bar row.
            if vm.progress != nil {
                ProgressView(value: vm.progress)
                    .accentColor(self.progressColor)
                    .progressViewStyle(.linear)
                    .frame(height: 8)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(.background.secondary)  // TODO: Use primary in light mode
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct BudgetRow: View {
    var title: String
    var text: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(text)
                .font(.subheadline)
        }
    }
}
