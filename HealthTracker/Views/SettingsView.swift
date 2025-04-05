// import SwiftData
// import SwiftUI

// struct SettingsView: View {
//     // Using AppStorage for persistent settings (example: Dark Mode)
//     @AppStorage("isDarkMode") private var isDarkMode: Bool = false
//     @State private var notificationsEnabled: Bool = true

//     var body: some View {
//         NavigationView {
//             Form {
//                 // Appearance Section
//                 Section(header: Text("Appearance")) {
//                     Toggle(isOn: $isDarkMode) {
//                         Text("Dark Mode")
//                     }
//                 }

//                 // Notifications Section
//                 Section(header: Text("Notifications")) {
//                     Toggle(isOn: $notificationsEnabled) {
//                         Text("Enable Notifications")
//                     }
//                 }

//                 // Account Section
//                 Section(header: Text("Account")) {
//                     NavigationLink(destination: AccountDetailsView()) {
//                         Text("Account Settings")
//                     }
//                 }

//                 // About Section
//                 Section(header: Text("About")) {
//                     NavigationLink(destination: AboutView()) {
//                         Text("Version Info")
//                     }
//                 }
//             }
//             .navigationTitle("Settings")
//         }
//     }
// }

// struct DailyCalorieBudgetView: View {
//     @Query.Singleton var calorieBudget: CalorieBudget
// }

// struct AboutView: View {
//     var body: some View {
//         VStack(spacing: 20) {
//             Text("Health Tracker")
//                 .font(.headline)
//             Text("Version 1.0.0")
//                 .font(.subheadline)

//             // Additional information can be added here
//         }
//         .padding()
//         .navigationTitle("About")
//     }
// }

// struct SettingsView_Previews: PreviewProvider {
//     static var previews: some View {
//         SettingsView()
//     }
// }
