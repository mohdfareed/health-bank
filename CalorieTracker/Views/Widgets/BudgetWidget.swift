import SwiftData
import SwiftUI

protocol BudgetVMProtocol {
    var name: String { get }
    var progress: Double? { get }
}

struct BudgetCard<Content: View>: View {
    @State var vm: BudgetVMProtocol
    @ViewBuilder var content: () -> Content
    private let color: Color
    private let progressColor: Color

    init(
        viewModel: BudgetVMProtocol,
        color: Color = Color.accentColor,
        progressColor: Color = Color.accentColor,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.vm = viewModel
        self.content = content
        self.color = color
        self.progressColor = progressColor
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header: Centered title.
            Text(vm.name)
                .font(.title).bold()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

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
        .background(self.color)
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
