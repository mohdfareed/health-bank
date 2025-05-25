// HealthBankApp.swift

import SwiftUI

@main
struct MainApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image.logo
                    .foregroundStyle(.logoGradient)
                    .imageScale(.large)
                    .font(.system(size: 60))

                Text("Health Bank")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Project Setup Complete")
                    .font(.title2)

                Divider()
                    .padding(.vertical)

                Text("Architecture Planning in Progress")
                    .font(.headline)

                Text("Ready for collaborative planning")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Health Bank")
        }
    }
}

#Preview {
    ContentView()
}
