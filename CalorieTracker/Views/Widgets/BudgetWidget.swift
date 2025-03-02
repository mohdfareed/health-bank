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
    private let progressColor: Color

    private var progressAccent: Color {
        if self.vm.progress == nil {
            return Color.clear
        }
        return self.vm.progress! > 0.8 ? Color.red : self.progressColor
    }

    init(
        viewModel: BudgetVMProtocol,
        color: Color = Color.accentColor,
        progressColor: Color = Color.primary,
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
                    .accentColor(self.progressAccent)
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
